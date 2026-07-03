{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.custom.backup;
  alertsCfg = config.services.custom.alerts;
  hostName = config.networking.hostName;

  # Prune policy, shared between the borgmatic settings and the daily summary
  # so the reported retention can't drift from what is actually kept.
  retention = {
    hourly = 12;
    daily = 14;
    weekly = 8;
    monthly = 6;
    yearly = 3;
  };

  summaryEnable = cfg.dailySummary.enable && alertsCfg.enable;

  # Posts a "backups OK" heartbeat with a per-repository breakdown. Runs
  # `borgmatic list --json` (one call covers all repos), then formats archive
  # counts and the age of the newest archive per repo.
  summaryScript = pkgs.writeShellScript "borgmatic-summary" ''
    set -euo pipefail

    # Render an ISO timestamp as a rough "Nh ago" / "Nd ago" age.
    fmt_age() {
      [ "$1" = "n/a" ] && { echo "n/a"; return; }
      h=$(( ( $(${pkgs.coreutils}/bin/date +%s) - $(${pkgs.coreutils}/bin/date -d "$1" +%s) ) / 3600 ))
      if [ "$h" -ge 48 ]; then echo "$(( h / 24 ))d ago"; else echo "''${h}h ago"; fi
    }

    json=$(borgmatic list --json)

    body="Keeps ${toString retention.hourly}h/${toString retention.daily}d/${toString retention.weekly}w/${toString retention.monthly}m/${toString retention.yearly}y"
    while IFS=$'\t' read -r repo n newest oldest; do
      body="$body
• $repo: $n archives, newest $(fmt_age "$newest"), oldest $(fmt_age "$oldest")"
    done < <(echo "$json" | ${pkgs.jq}/bin/jq -r '
      .[]
      | [ (.repository.label // .repository.location),
          (.archives | length | tostring),
          (.archives[-1].time // "n/a"),
          (.archives[0].time // "n/a") ]
      | @tsv')

    # Server disk and memory snapshot.
    read -r disk_used disk_free < <(${pkgs.coreutils}/bin/df -h --output=pcent,avail / | ${pkgs.coreutils}/bin/tail -1)
    mem_pct=$(${pkgs.gawk}/bin/awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "%d",(t-a)*100/t}' /proc/meminfo)
    body="$body

Disk: $disk_used used, $disk_free free
Memory: ''${mem_pct}% used"

    ${alertsCfg.ntfySend} ${alertsCfg.topic} "Backups OK (${hostName})" "$body" min white_check_mark
  '';
in
{
  options.services.custom.backup = {
    enable = mkEnableOption "borgmatic offsite backups to the Hetzner storage boxes";

    repositories = mkOption {
      type = types.listOf (types.attrsOf types.str);
      default = [
        {
          # Falkenstein (DE) storage box
          path = "ssh://u487410@u487410.your-storagebox.de:23/./borg/${hostName}";
          label = "falkenstein";
        }
        {
          # Helsinki (FI) storage box
          path = "ssh://u489939@u489939.your-storagebox.de:23/./borg/${hostName}";
          label = "helsinki";
        }
      ];
      description = "Borg repositories to back up to, one per storage box (geo-redundant).";
    };

    sourceDirectories = mkOption {
      type = types.listOf types.str;
      default = [
        "/var/lib/vaultwarden"
        "/var/lib/forgejo"
        "/var/lib/ntfy-sh"
      ];
      description = "Directories to include in the backup.";
    };

    passphraseFile = mkOption {
      type = types.path;
      default = config.sops.secrets."borg/${hostName}-passphrase".path;
      description = "File containing the borg repository encryption passphrase.";
    };

    dailySummary = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Send a once-daily "backups OK" notification listing, per repository,
          the archive count and how fresh the latest archive is. Doubles as a
          dead-man's-switch: if the summary stops arriving, the backup pipeline
          has silently died. Requires services.custom.alerts to be enabled.
        '';
      };

      time = mkOption {
        type = types.str;
        default = "08:00";
        description = "OnCalendar expression for when the daily summary is sent.";
      };
    };
  };

  config = mkIf cfg.enable {
    # Repository encryption passphrase (provisioned via sops, root-owned).
    sops.secrets."borg/${hostName}-passphrase" = { };

    # System-wide SSH host config so root's borgmatic selects the right
    # per-box key automatically when it connects via the repo URL. Mirrors
    # the per-user setup in home/features/ssh/backup.nix.
    programs.ssh.extraConfig = ''
      Host u487410.your-storagebox.de
        User u487410
        Port 23
        IdentityFile /run/secrets/storagebox/falkenstein-ssh-key

      Host u489939.your-storagebox.de
        User u489939
        Port 23
        IdentityFile /run/secrets/storagebox/helsinki-ssh-key
    '';

    services.borgmatic = {
      enable = true;
      settings = {
        source_directories = cfg.sourceDirectories;
        repositories = cfg.repositories;

        encryption_passcommand = "${pkgs.coreutils}/bin/cat ${cfg.passphraseFile}";
        ssh_command = "ssh";

        exclude_if_present = [ ".nobackup" ];

        # Consistent point-in-time snapshot of Vaultwarden's database, taken
        # before the filesystem archive runs. Forgejo's Postgres data is
        # captured through its own dump zip under /var/lib/forgejo, so no
        # postgresql hook is needed here.
        sqlite_databases = [
          {
            name = "vaultwarden";
            path = "/var/lib/vaultwarden/db.sqlite3";
          }
        ];

        keep_hourly = retention.hourly;
        keep_daily = retention.daily;
        keep_weekly = retention.weekly;
        keep_monthly = retention.monthly;
        keep_yearly = retention.yearly;

        checks = [
          {
            name = "repository";
            frequency = "2 weeks";
          }
          {
            name = "archives";
            frequency = "6 weeks";
          }
          {
            name = "extract";
            frequency = "12 weeks";
          }
        ];
      };
    };

    # Run hourly instead of the borgmatic package's default daily timer.
    systemd.timers.borgmatic.timerConfig.OnCalendar = mkForce "hourly";

    # The sqlite dump hook shells out to the sqlite3 binary.
    systemd.services.borgmatic.path = [ pkgs.sqlite ];

    # Reuse the ntfy alert template from services.custom.alerts to notify on
    # backup failures, like the other monitored units.
    systemd.services.borgmatic.unitConfig.OnFailure =
      mkIf alertsCfg.enable [ "ntfy-alert@borgmatic.service" ];

    # Daily "backups OK" heartbeat with a per-repository breakdown. A failed
    # run alerts through the same template, so a broken summary is visible too.
    systemd.services.borgmatic-summary = mkIf summaryEnable {
      description = "Daily borgmatic backup summary notification";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = [ pkgs.borgmatic pkgs.borgbackup pkgs.openssh pkgs.sqlite ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = summaryScript;
      };
      unitConfig.OnFailure = [ "ntfy-alert@borgmatic-summary.service" ];
    };

    systemd.timers.borgmatic-summary = mkIf summaryEnable {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.dailySummary.time;
        Persistent = true;
      };
    };
  };
}
