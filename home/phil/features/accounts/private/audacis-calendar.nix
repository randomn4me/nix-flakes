{ config, pkgs, lib, ... }:
let
  cat = "${pkgs.coreutils}/bin/cat";
  home = config.home.homeDirectory;
in {
  imports = [ ../vdirsyncer.nix ];
  accounts.calendar = {
    basePath = "${home}/var/calendar";

    accounts.audacis = {
      primary = lib.mkDefault false;

      local = {
        type = "filesystem";
        fileExt = ".ics";
      };

      remote = rec {
        userName = "philippkuehn";
        passwordCommand = [ "${cat}" "${home}/usr/misc/cloud.audacis.net" ];
        type = "caldav";
        url = "https://cloud.audacis.net/remote.php/dav";
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
