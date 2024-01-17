{ config, pkgs, lib, ... }:
let
  cat = "${pkgs.coreutils}/bin/cat";
  home = config.home.homeDirectory;
in {
  imports = [ ../vdirsyncer.nix ];

  accounts.calendar = {
    basePath = "${home}/var/calendar";

    accounts.peasec = {
      primary = lib.mkDefault false;

      local = {
        type = "filesystem";
        fileExt = ".ics";
      };

      remote = rec {
        userName = "ba01viny";
        passwordCommand = [ "${cat}" "${home}/usr/misc/${userName}" ];
        type = "caldav";
        url =
          "https://mail.tu-darmstadt.de:1443/users/kuehn@peasec.tu-darmstadt.de/calendar";
      };

      vdirsyncer = {
        enable = true;
        collections = [ "from a" "from b" ];
        conflictResolution = "remote wins";
        metadata = [ "color" ];
      };
    };
  };
}
