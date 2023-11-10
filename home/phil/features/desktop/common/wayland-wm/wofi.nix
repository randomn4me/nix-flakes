{ config, ... }:
let inherit (config.colorscheme) colors;
in {
  programs.wofi = {
    enable = true;

    settings = {
      width = "400px";
      lines = 8;
      matching = "fuzzy";
      insensitive = true;
      location = "center";
      prompt = "Search..";
    };

    style = ''
      * {
          font: Share Tech Mono;
          font-size: 18px;
      }

      #window,
      #input {
          margin: 2px;
          border: 2px solid;
          border-radius: 8px;
          border-color: #${colors.base09};
          background-color: #${colors.base02};
      }

      #input {
          border: 0px;
          color: #${colors.base09};
      }

      #entry {
          border-radius: 5px;
          color: #${colors.base05};
      }


      #entry:selected {
          background-color: #${colors.base09};
          color: #${colors.base01};
      }

      #inner-box {
          margin: 4px;
      }
    '';
  };

  home.file.".local/bin/shutdown-menu" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      res=$(printf "logout\nreboot\nsuspend\nshutdown" | wofi --show dmenu)

      case "$res" in
        "logout")   loginctl terminate-user ${config.home.username} ;;
        "reboot")   systemctl reboot ;;
        "suspend")  systemctl suspend ;;
        "shutdown") systemctl poweroff ;;
      esac

      exit 0
    '';
  };
  
  home.file.".local/bin/paper-menu" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      cd ${config.home.homeDirectory}/usr/docs/zotero-paper
      pdffile=$(fd 'pdf$' | wofi --show dmenu)

      xdg-open "$pdffile" &
    '';
  };
}
