{ config, lib, pkgs, unstable, host, ... }:

{
  home.file.".config/hypr" = {
    source = ./hypr;
    recursive = true;
  };

  home.file.".local/bin" = {
    source = ./bin;
    recursive = true;
  };

  systemd.user.sessionVariables = {
    "NIXOS_OZONE_WL" = "1"; # for any ozone-based browser & electron apps to run on wayland
    "MOZ_ENABLE_WAYLAND" = "1"; # for firefox to run on wayland
    "MOZ_WEBRENDER" = "1";
  };
}
