{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.custom.backup;
  alertsCfg = config.services.custom.alerts;
  hostName = config.networking.hostName;
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

        keep_hourly = 12;
        keep_daily = 14;
        keep_weekly = 8;
        keep_monthly = 6;
        keep_yearly = 3;

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
  };
}
