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
              path = "ssh://u340000@u340000.your-storagebox.de:23/./borg/${osConfig.networking.hostName}";
              label = "remote";
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
          encryptionPasscommand = "${cat} ${home}/usr/misc/borg";
          extraConfig = {
            ssh_command = "ssh -i ${home}/.ssh/storagebox";
          };
        };

        retention = {
          keepHourly = 6;
          keepDaily = 14;
          keepWeekly = 8;
          keepMonthly = 6;
          keepYearly = 3;
        };

        consistency = {
          checks = [
            {
              name = "repository";
              frequency = "1 weeks";
            }
            {
              name = "archives";
              frequency = "2 weeks";
            }
            {
              name = "data";
              frequency = "8 weeks";
            }
            {
              name = "extract";
              frequency = "8 weeks";
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
