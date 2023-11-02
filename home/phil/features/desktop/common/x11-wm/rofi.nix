{ config, ... }:
{
  programs.rofi = {
    enable = true;

    font = "Share Tech Mono 18";

    location = "center";
    terminal = config.home.sessionVariables.TERMINAL;

    cycle = true;
  };

  home.file.".local/bin/shutdown-menu" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      res=$(printf "logout\nreboot\nsuspend\nshutdown" | rofi --show dmenu)

      case "$res" in
        "logout")   loginctl terminate-user ${config.home.username} ;;
        "reboot")   systemctl reboot ;;
        "suspend")  systemctl suspend ;;
        "shutdown") systemctl poweroff ;;
      esac

      exit 0
    '';
  };
}
