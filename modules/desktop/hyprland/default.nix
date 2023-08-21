{ config, lib, pkgs, host, system, hyprland, ... }:

let
  exec = "exec dbus-launch Hyprland";
in
{
  programs = {
    hyprland = {
      enable = true;

      xwayland = {
        enable = true;
	hidpi = true;
      };

      #light.enable = true;

      package = hyprland.packages.${pkgs.system}.hyprland;
    };
  };

  xdg.portal = {
    enable = true;
  };

  environment = {
    loginShellInit = ''
      if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
        ${exec}
      fi
    '';
    systemPackages = with pkgs; [
      waybar
      swaybg
      swayidle
      swaylock
      wl-clipboard
      hyprpicker
      jq
      inotify-tools

      grim
      slurp

      mako
    ];
  };

} 
