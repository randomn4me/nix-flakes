{ config, lib, pkgs, host, ... }:

{
  home.file.".config/hypr" = {
    source = ./hypr;
    recursive = true;
  };

  home.file.".config/waybar" = {
    source = ./waybar;
    recursive = true;
  };

  home.file.".config/mako" = {
    source = ./mako;
    recursive = true;
  };

  home.file."bin/hyprland" = {
    source = ./bin;
    recursive = true;
  };

  systemd.user.sessionVariables = {
    "NIXOS_OZONE_WL" = "1"; # for any ozone-based browser & electron apps to run on wayland
    "MOZ_ENABLE_WAYLAND" = "1"; # for firefox to run on wayland
    "MOZ_WEBRENDER" = "1";
  };
}
