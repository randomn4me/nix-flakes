{ config, pkgs, ... }:
let
  cat = "${pkgs.coreutils}/bin/cat";
  home = config.home.homeDirectory;
in
{
  imports = [ ../vdirsyncer.nix ];

  accounts.contact = {
    basePath = "${home}/var/contacts";

    accounts.audacis = {
      local = {
        type = "filesystem";
        fileExt = ".vcf";
      };

      remote = {
        userName = "philippkuehn";
        passwordCommand = [
          cat
          "${home}/usr/misc/cloud.audacis.net"
        ];
        url = "https://cloud.audacis.net/remote.php/dav";
        type = "carddav";
      };

      vdirsyncer = {
        enable = true;
        collections = [
          "from b"
          "from a"
        ];
        conflictResolution = "remote wins";
        metadata = [ "displayname" ];
      };
    };
  };
}
