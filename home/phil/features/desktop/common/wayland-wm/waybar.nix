{ config, pkgs, ... }:

let
  # Dependencies
  pgrep = "${pkgs.procps}/bin/pgrep";

  date = "${pkgs.coreutils}/bin/date";
  ls = "${pkgs.coreutils}/bin/ls";
  paste = "${pkgs.coreutils}/bin/paste";
  wc = "${pkgs.coreutils}/bin/wc";

  fd = "${pkgs.fd}/bin/fd";
  bc = "${pkgs.bc}/bin/bc";
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      primary = {
        layer = "top";
        height = 15;
        margin = "5 5 0 5";
        position = "top";

        modules-left = [
          "pulseaudio"
          "battery"
          "hyprland/workspaces"
        ];
        modules-center = [
          "mpd"
        ];
        modules-right = [
          "tray"
          "custom/date"
          "custom/clock"
        ];

        "hyprland/workspaces" = {
          active-only = true;
          all-outputs = true;
          persistent-workspaces = {
            "*" = 10;
          };
          #format = "{icon}";
          #format-icons = {
          #  "1" = "";
          #  "2" = "";
          #  "3" = "";
          #  "4" = "";
          #  "5" = "󰈹";
          #  "6" = "";
          #  "7" = "";
          #  "8" = "";
          #  "9" = "󰝚";
          #};
        };

        pulseaudio = {
          format = "{volume}";
          format-muted = "M";
          on-click = pavucontrol;
        };

        mpd = {
          "interval" = 3;
          "format" = "{artist} - {title}";
        };

        battery = {
          interval = 10;
          #format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          format = "{capacity}";
          #format = "{icon} {capacity}";
          format-charging = "{capacity}+";
          format-plugged = "{capacity}+";
          #format-charging = "󰂄 {capacity}";
          #format-plugged = "󰂄 {capacity}";
          onclick = "";
        };

        tray = {
          icon-size = 15;
          spacing = 5;
        };

        "custom/clock" = {
          format = "{}";
          exec = "${date} +%H:%M";
          interval = 1;
        };

        "custom/date" = {
          format = "{}";
          exec = "${date} +%d-%m";
          interval = 60;
        };

        #"custom/unread-mail" = {
        #  interval = 5;
        #  exec = "while read -r line; do ${ls} $line | ${wc} -l; done <<< for dir in `${fd} Inbox ~/var/mail`; do ${fd} new $dir; done | ${paste} -sd'+' | ${bc}";
        #  format = "{}";
        #};
      };
    };
    # Cheatsheet:
    # x -> all sides
    # x y -> vertical, horizontal
    # x y z -> top, horizontal, bottom
    # w x y z -> top, right, bottom, left
    style = let inherit (config.colorscheme) colors; in /* css */ ''
      * {
        border: none;
        border-radius: 5px;

        font-family: Share Tech Mono;
        font-size: 12pt;

        padding: 0 10px;
        margin: 0 5px;

        color: #${colors.base00};
      }

      tooltip {
        background: #${colors.base00};
        border: 1px solid #${colors.base09};
      }

      tooltip label {
        color: #${colors.base05};
      }

      window#waybar {
        background: transparent;
      }

      window#waybar.hidden {
        opacity: 0.2;
      }

      #pulseaudio, #custom-clock {
        background: #${colors.base09};
      }

      #battery, #custom-date {
        background: #${colors.base08};
      }

      #tray {
        background: #${colors.base0A};
      }

      /*
      #custom-mail {
        background: #${colors.base0C};
      }
      */

      #battery.discharging.critical {
        background: #${colors.base08};
      }
      #battery.charging {
        background: #${colors.base0D};
      }


      #workspaces {
        background-color: #${colors.base03};
        padding: 0;
        margin: 0;
      }

      #workspaces button {
        padding: 0;
        margin: 0;
      }

      #workspaces button.active {
        background-color: #${colors.base0A};
        color: #${colors.base0A};
      }

      #workspaces button.urgent {
        background-color: #${colors.base0F};
      }


      #mpd {
        background: #${colors.base0C};
      }

      #mpd.disconnected,
      #mpd.stopped {
        background: transparent;
      }

    '';
  };
}
