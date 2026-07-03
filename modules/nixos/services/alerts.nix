{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.custom.alerts;
  ntfyCfg = config.services.custom.ntfy;

  ntfySend = pkgs.writeShellScript "ntfy-send" ''
    TOPIC="$1"
    TITLE="$2"
    MESSAGE="$3"
    PRIORITY="''${4:-default}"
    TAGS="''${5:-}"

    TOKEN=$(cat ${cfg.ntfyTokenFile})

    ${pkgs.curl}/bin/curl -sSf \
      -H "Authorization: Bearer $TOKEN" \
      -H "Title: $TITLE" \
      -H "Priority: $PRIORITY" \
      -H "Tags: $TAGS" \
      -d "$MESSAGE" \
      "http://${ntfyCfg.listenAddress}/$TOPIC"
  '';

  # Sample 5-minute load and memory pressure; alert on sustained saturation,
  # rate-limited by a per-metric stamp file so a persistent condition pages at
  # most once per cooldown window (and re-arms once it recovers).
  resourceScript = pkgs.writeShellScript "resource-alert" ''
    set -euo pipefail

    STATE=/run/resource-alert
    ${pkgs.coreutils}/bin/mkdir -p "$STATE"
    now=$(${pkgs.coreutils}/bin/date +%s)
    cooldown=${toString cfg.resources.cooldown}

    cooled() {
      f="$STATE/$1"
      if [ -f "$f" ]; then
        age=$(( now - $(${pkgs.coreutils}/bin/cat "$f") ))
        [ "$age" -lt "$cooldown" ] && return 1
      fi
      return 0
    }
    mark() { echo "$now" > "$STATE/$1"; }
    rearm() { ${pkgs.coreutils}/bin/rm -f "$STATE/$1"; }

    ncpu=$(${pkgs.coreutils}/bin/nproc)
    load5=$(${pkgs.coreutils}/bin/cut -d' ' -f2 /proc/loadavg)
    cpu_pct=$(${pkgs.gawk}/bin/awk -v l="$load5" -v n="$ncpu" 'BEGIN{printf "%d", l*100/n}')
    if [ "$cpu_pct" -ge ${toString cfg.resources.cpuThreshold} ]; then
      if cooled cpu; then
        ${ntfySend} ${cfg.topic} "High CPU (${config.networking.hostName})" "5-min load at ''${cpu_pct}% of $ncpu cores" high warning
        mark cpu
      fi
    else
      rearm cpu
    fi

    mem_pct=$(${pkgs.gawk}/bin/awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "%d",(t-a)*100/t}' /proc/meminfo)
    if [ "$mem_pct" -ge ${toString cfg.resources.memThreshold} ]; then
      if cooled mem; then
        ${ntfySend} ${cfg.topic} "High Memory (${config.networking.hostName})" "memory at ''${mem_pct}% used" high warning
        mark mem
      fi
    else
      rearm mem
    fi
  '';
in
{
  options.services.custom.alerts = {
    enable = mkEnableOption "ntfy-based system alerts";

    ntfyTokenFile = mkOption {
      type = types.path;
      description = "Path to file containing the ntfy access token";
    };

    topic = mkOption {
      type = types.str;
      default = "alerts-${config.networking.hostName}";
      description = "Default ntfy topic for alerts";
    };

    ntfySend = mkOption {
      type = types.path;
      readOnly = true;
      default = ntfySend;
      description = ''
        Reusable helper script that posts a message to ntfy. Other modules can
        call it to send notifications through the same token/topic.
        Usage: ntfySend <topic> <title> <message> [priority] [tags]
      '';
    };

    fail2ban.enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Send an ntfy notification on every fail2ban ban. Off by default: bans
        are constant background noise from bots and add little signal. Disabling
        this only stops the notifications — fail2ban keeps banning either way.
      '';
    };

    fail2ban.priority = mkOption {
      type = types.enum [ "min" "low" "default" "high" "urgent" ];
      default = "low";
      description = ''
        ntfy priority for fail2ban ban notifications. Bans are frequent and
        routine, so this defaults to "low" (delivered silently, no sound or
        vibration). Use "min" to only show them in the notification drawer.
      '';
    };

    systemdServices = mkOption {
      type = types.listOf types.str;
      default = [ "forgejo" "vaultwarden" "postgresql" "nginx" "ntfy-sh" ];
      description = "Systemd services to monitor for failure";
    };

    diskSpace = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable disk space monitoring";
      };

      threshold = mkOption {
        type = types.int;
        default = 90;
        description = "Disk usage percentage threshold for alerts";
      };

      interval = mkOption {
        type = types.str;
        default = "hourly";
        description = "How often to check disk space";
      };
    };

    resources = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Flag sustained high CPU or memory usage";
      };

      cpuThreshold = mkOption {
        type = types.int;
        default = 95;
        description = ''
          Flag when the 5-minute load average, as a percentage of available CPU
          cores, reaches this value (~95% ≈ cores saturated for 5 minutes).
        '';
      };

      memThreshold = mkOption {
        type = types.int;
        default = 95;
        description = "Flag when used memory (of total) reaches this percentage";
      };

      interval = mkOption {
        type = types.str;
        default = "*:0/5";
        description = "How often to sample CPU and memory (OnCalendar expression)";
      };

      cooldown = mkOption {
        type = types.int;
        default = 3600;
        description = "Minimum seconds between repeat alerts while a metric stays over threshold";
      };
    };

    acme.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Send alerts on ACME certificate renewal failures";
    };

    forgejoBackup.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Send alerts on Forgejo backup failures";
    };

    nixGc.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Send alerts on Nix garbage collection failures";
    };
  };

  config = mkIf cfg.enable {
    systemd.services = let
      # OnFailure overrides for monitored services
      serviceOverrides = builtins.listToAttrs (map (svc: {
        name = svc;
        value = {
          unitConfig.OnFailure = [ "ntfy-alert@${svc}.service" ];
        };
      }) cfg.systemdServices);

      # ACME certificate renewal failure alerts
      acmeOverrides = let
        acmeDomains = builtins.attrNames (filterAttrs (_: vhost: vhost.enableACME or false) config.services.nginx.virtualHosts);
      in mkIf cfg.acme.enable (builtins.listToAttrs (map (domain: {
        name = "acme-${domain}";
        value = {
          unitConfig.OnFailure = [ "ntfy-alert@acme-${domain}.service" ];
        };
      }) acmeDomains));

      # Forgejo backup failure alert
      forgejoOverride = mkIf (cfg.forgejoBackup.enable && config.services.forgejo.dump.enable or false) {
        forgejo-dump.unitConfig.OnFailure = [ "ntfy-alert@forgejo-dump.service" ];
      };

      # Nix GC failure alert
      nixGcOverride = mkIf cfg.nixGc.enable {
        nix-gc.unitConfig.OnFailure = [ "ntfy-alert@nix-gc.service" ];
      };

    in mkMerge [
      # Template service for systemd failure notifications
      {
        "ntfy-alert@" = {
          description = "Send ntfy alert for %i failure";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${ntfySend} ${cfg.topic} 'Service Failed: %i' '${config.networking.hostName}: unit %i has failed' urgent rotating_light";
          };
        };
      }

      serviceOverrides
      acmeOverrides
      forgejoOverride
      nixGcOverride

      # Disk space monitoring
      (mkIf cfg.diskSpace.enable {
        disk-space-alert = {
          description = "Check disk space and alert if above threshold";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = pkgs.writeShellScript "check-disk-space" ''
              USAGE=$(${pkgs.coreutils}/bin/df / --output=pcent | ${pkgs.coreutils}/bin/tail -1 | ${pkgs.coreutils}/bin/tr -d ' %')
              if [ "$USAGE" -ge ${toString cfg.diskSpace.threshold} ]; then
                ${ntfySend} ${cfg.topic} "Disk Space Warning" "${config.networking.hostName}: disk usage at ''${USAGE}%" high warning
              fi
            '';
          };
        };
      })

      # CPU / memory pressure monitoring
      (mkIf cfg.resources.enable {
        resource-alert = {
          description = "Flag sustained high CPU or memory usage";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = resourceScript;
          };
        };
      })
    ];

    systemd.timers.disk-space-alert = mkIf cfg.diskSpace.enable {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.diskSpace.interval;
        Persistent = true;
      };
    };

    systemd.timers.resource-alert = mkIf cfg.resources.enable {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.resources.interval;
      };
    };

    # Fail2ban ntfy action
    environment.etc = mkIf cfg.fail2ban.enable {
      "fail2ban/action.d/ntfy.local".text = ''
        [Definition]
        actionban = ${ntfySend} ${cfg.topic} "Fail2ban: <name>" "${config.networking.hostName}: banned <ip> in jail <name> (<failures> failures)" ${cfg.fail2ban.priority} lock
        actionunban =
      '';
    };

    services.fail2ban.jails = mkIf cfg.fail2ban.enable {
      DEFAULT.settings = {
        action = "%(action_)s\n           ntfy";
      };
    };
  };
}
