{
  config,
  pkgs,
  osConfig,
  ...
}:
let
  cat = "${pkgs.coreutils}/bin/cat";
  home = config.home.homeDirectory;
in
{
  imports = [ ../ssh/backup.nix ];

  services.borgmatic = {
    enable = true;
  };

  programs.borgmatic = {
    enable = true;

    backups = {
      peasec = {
        location = {
          sourceDirectories = [
            "${home}/etc"
            "${home}/src"
            "${home}/tmp"
            "${home}/usr"
            "${home}/var"
          ];
          repositories = [
            {
              # Falkenstein (DE) storage box
              path = "ssh://u487410@u487410.your-storagebox.de:23/./borg/${osConfig.networking.hostName}";
              label = "falkenstein";
            }
            {
              # Helsinki (FI) storage box
              path = "ssh://u489939@u489939.your-storagebox.de:23/./borg/${osConfig.networking.hostName}";
              label = "helsinki";
            }
            {
              path = "/run/media/phil/backup/borg-backup";
              label = "hdd";
            }
          ];

          excludeHomeManagerSymlinks = true;

          extraConfig = {
            exclude_if_present = [ ".nobackup" ];
          };
        };

        storage = {
          # Passphrase provisioned by sops (owner: phil) on the peasec host.
          encryptionPasscommand = "${cat} /run/secrets/borg/${osConfig.networking.hostName}-passphrase";
          extraConfig = {
            # Per-box key selection is handled by ~/.ssh/config (see ssh/backup.nix).
            ssh_command = "ssh";
          };
        };

        retention = {
          keepHourly = 12;
          keepDaily = 14;
          keepWeekly = 8;
          keepMonthly = 6;
          keepYearly = 3;
        };

        consistency = {
          checks = [
            {
              name = "repository";
              frequency = "2 weeks";
            }
            {
              name = "archives";
              frequency = "6 weeks";
            }
            #{
            #  name = "data";
            #  frequency = "12 weeks";
            #}
            {
              name = "extract";
              frequency = "12 weeks";
            }
          ];
        };
      };
    };
  };

  home.file."usr/vids/movies/.nobackup".text = "";
  home.file."usr/vids/anime/.nobackup".text = "";
  home.file."usr/vids/photos/.nobackup".text = "";
  home.file."var/vms/.nobackup".text = "";
  home.file."tmp/.nobackup".text = "";
}
