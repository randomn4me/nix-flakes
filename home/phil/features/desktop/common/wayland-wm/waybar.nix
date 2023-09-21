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
          #"custom/unread-mail"
        ];
        modules-center = [
          "custom/00"
          "custom/01"
          "custom/02"
          "custom/03"
          "custom/04"
          "custom/05"
          "custom/06"
          "custom/07"
          "custom/08"
          "custom/09"
          "custom/0A"
          "custom/0B"
          "custom/0C"
          "custom/0D"
          "custom/0E"
          "custom/0F"
        ];
        modules-right = [
          "custom/date"
          "custom/clock"
        ];


        pulseaudio = {
          format = "{volume}";
          format-muted = "M";
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

        "custom/00" = { format = "00"; };
        "custom/01" = { format = "01"; };
        "custom/02" = { format = "02"; };
        "custom/03" = { format = "03"; };
        "custom/04" = { format = "04"; };
        "custom/05" = { format = "05"; };
        "custom/06" = { format = "06"; };
        "custom/07" = { format = "07"; };
        "custom/08" = { format = "08"; };
        "custom/09" = { format = "09"; };
        "custom/0A" = { format = "0A"; };
        "custom/0B" = { format = "0B"; };
        "custom/0C" = { format = "0C"; };
        "custom/0D" = { format = "0D"; };
        "custom/0E" = { format = "0E"; };
        "custom/0F" = { format = "0F"; };

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

        font-size: 12pt;

        padding: 0 10px;
        margin: 0 5px;

        color: #${colors.base00};
      }

      window#waybar {
        background: transparent;
      }

      #pulseaudio {
        background: #${colors.base06};
      }
      #battery {
        background: #${colors.base07};
      }
      #battery.discharging.critical {
        background: #${colors.base08};
      }
      #battery.charging {
        background: #${colors.base0D};
      }

      /*
      #custom-mail {
        background: #${colors.base0C};
      }
      */

      #mpd {
        background: #${colors.base0D};
      }

      #mpd.disconnected,
      #mpd.stopped {
        background: transparent;
      }

      #custom-date {
        background: #${colors.base08};
      }

      #custom-clock {
        background: #${colors.base09};
      }

      #custom-00 { background: #${colors.base00}; color: #${colors.base05}; }
      #custom-01 { background: #${colors.base01}; color: #${colors.base05}; }
      #custom-02 { background: #${colors.base02}; color: #${colors.base05}; }
      #custom-03 { background: #${colors.base03}; color: #${colors.base05}; }
      #custom-04 { background: #${colors.base04}; color: #${colors.base05}; }
      #custom-05 { background: #${colors.base05}; }
      #custom-06 { background: #${colors.base06}; }
      #custom-07 { background: #${colors.base07}; }
      #custom-08 { background: #${colors.base08}; }
      #custom-09 { background: #${colors.base09}; }
      #custom-0A { background: #${colors.base0A}; }
      #custom-0B { background: #${colors.base0B}; }
      #custom-0C { background: #${colors.base0C}; }
      #custom-0D { background: #${colors.base0D}; }
      #custom-0E { background: #${colors.base0E}; }
      #custom-0F { background: #${colors.base0F}; }
    '';
  };
}
