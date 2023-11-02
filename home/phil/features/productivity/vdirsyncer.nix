{ pkgs, lib, config, ... }:
let
  cat = "${pkgs.coreutils}/bin/cat";
  home = config.home.homeDirectory;
in {
  home.packages = with pkgs; [ vdirsyncer ];

  xdg.configFile."vdirsyncer/config".text = ''
    [general]
    status_path = "${home}/.cache/vdirsyncer/status/"

    # CARDDAV
    [pair audacis_contacts]
    a = "audacis_contacts_local"
    b = "audacis_contacts_remote"
    collections = ["from a", "from b"]
    conflict_resolution = "b wins"
    metadata = ["displayname"]

    [storage audacis_contacts_local]
    type = "filesystem"
    path = "${home}/var/vdirsyncer/audacis_contacts/"
    fileext = ".vcf"

    [storage audacis_contacts_remote]
    type = "carddav"
    url = "https://cloud.audacis.net/remote.php/dav/"
    username = "philippkuehn"
    password.fetch = ["command", "${cat}", "${home}/usr/misc/cloud.audacis.net"]
  '';

  services.vdirsyncer.enable = true;
}
