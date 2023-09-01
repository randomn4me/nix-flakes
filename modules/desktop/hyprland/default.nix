{ config, lib, pkgs, host, system, ... }:

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
      libnotify

      grim
      slurp

      mako
    ];
  };

} 
