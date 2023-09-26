{ config, pkgs, ...}:
let
  cat = "${pkgs.coreutils}/bin/cat";
  home = config.home.homeDirectory;
in
{
  services.borgmatic = {
    enable = true;
  };

  programs.borgmatic = {
    enable = true;

    backups = {
      work = {
        location = {
          sourceDirectories = [
            "${home}/etc"
            "${home}/src"
            "${home}/tmp"
            "${home}/usr"
            "${home}/var"
          ];

          excludeHomeManagerSymlinks = true;

          repositories = [
            "ssh://u340000@u340000.your-storagebox.de:23/./backups/t490"
          ];
        };

        storage = {
          encryptionPasscommand = "${cat} ${home}/usr/misc/borg";
          extraConfig = { ssh_command =  "ssh -i /home/phil/.ssh/storagebox"; };
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
            { name = "repository"; frequency = "1 weeks"; }
            { name = "archives"; frequency = "2 weeks"; }
          ];
        };
      };
    };
  };
}
