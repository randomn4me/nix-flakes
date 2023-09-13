{ outputs, config, lib, pkgs, ... }:

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
          "custom/unread-mail"
        ];
        modules-center = [
          "mpd"
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
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰂄 {capacity}%";
          onclick = "";
        };

        #"custom/vol" = {
        #  format = "{}";
        #  exec = "${date} +%H-%M";
        #  interval = 1;
        #};

        "custom/clock" = {
          format = "{}";
          exec = "${date} +%H-%M";
          interval = 1;
        };

        "custom/date" = {
          format = "{}";
          exec = "${date} +%d-%m";
          interval = 60;
        };

        "custom/unread-mail" = {
          interval = 5;
          exec = "while read -r line; do ${ls} $line | ${wc} -l; done <<< for dir in `${fd} Inbox ~/var/mail`; do ${fd} new $dir; done | ${paste} -sd'+' | ${bc}";
          format = "{}";
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

        font-family: ${config.fontProfiles.regular.family}, ${config.fontProfiles.monospace.family};
        font-size: 12pt;

        padding: 0 10px;
        margin: 0 5px;

        color: #${colors.base00};
      }

      window#waybar {
        background: transparent;
      }

      #custom-vol {
        background: #${colors.base08};
      }
      #battery {
        background: #${colors.base0A};
      }
      #battery.discharging.critical {
        background: #${colors.base08};
      }
      #battery.charging {
        background: #${colors.base0D};
      }

      #custom-mail {
        background: #${colors.base0C};
      }

      #mpd {
        background: #${colors.base0D};
      }

      #mpd.disconnected,
      #mpd.stopped {
        background: transparent;
      }

      #custom-date {
        background: #${colors.base0C};
      }

      #custom-clock {
        background: #${colors.base0A};
      }
    '';
  };
}
