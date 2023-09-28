{ config, pkgs, ... }:

let
  # Dependencies
  date = "${pkgs.coreutils}/bin/date";
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
          "clock"
        ];

        "hyprland/workspaces" = {
          active-only = true;
          all-outputs = true;
          sort-by = "id";
          #persistent-workspaces = {
          #  "*" = 10;
          #};
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

        clock = {
          interval = 1;
          format = "{:%d.%m %H:%M}";
          format-alt = "{:%F %T %z}";
          tooltip-format = ''
            <tt><small>{calendar}</small></tt>
          '';
          calendar = {
            mode           = "month";
            mode-mon-col   = 3;
            weeks-pos      = "left";
            on-scroll      = 1;
            format = let inherit (config.colorscheme) colors; in  {
              months =   "<span color='#${colors.base05}'><b>{}</b></span>";
              days =     "<span color='#${colors.base05}'>{}</span>";
              weeks =    "<span color='#${colors.base0D}'><b>{}</b></span>";
              weekdays = "<span color='#${colors.base0B}'><b>{}</b></span>";
              today =    "<span color='#${colors.base0F}'><b>{}</b></span>";
            };
          };
          "actions" =  {
            on-click-right = "mode";
            on-click-forward = "tz_up";
            on-click-backward = "tz_down";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
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
        border: 2px solid #${colors.base09};
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

      #pulseaudio, #clock {
        background: #${colors.base09};
      }

      #battery, #tray {
        background: #${colors.base08};
      }

      /*
      #custom-mail {
        background: #${colors.base0C};
      }
      */

      #battery.discharging.critical {
        background: #${colors.base0F};
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