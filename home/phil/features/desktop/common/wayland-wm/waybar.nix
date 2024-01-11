{ config, pkgs, ... }:

let
  # Dependencies
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";

  alacritty = "${config.programs.alacritty.package}/bin/alacritty";
  ncmpcpp = "${config.programs.ncmpcpp.package}/bin/ncmpcpp";
  neomutt = "${config.programs.neomutt.package}/bin/neomutt";
  task = "${config.programs.taskwarrior.package}/bin/task";
  sptlrx = "${pkgs.sptlrx}/bin/sptlrx";

  playerctl = "${config.services.playerctld.package}/bin/playerctl";

  #cat = "${pkgs.coreutils}/bin/cat";
  #echo = "${pkgs.coreutils}/bin/echo";
  head = "${pkgs.coreutils}/bin/head";
  pkill = "${pkgs.coreutils}/bin/pkill";
  printf = "${pkgs.coreutils}/bin/printf";
  wc = "${pkgs.coreutils}/bin/wc";

  grep = "${pkgs.gnugrep}/bin/grep";

  pgrep = "${pkgs.procps}/bin/pgrep";
  ip = "${pkgs.iproute}/bin/ip";

  jq = "${pkgs.jq}/bin/jq";
  find = "${pkgs.findutils}/bin/find";

  khal = "${pkgs.khal}/bin/khal";

  # Function to simplify making waybar outputs
  jsonOutput = name:
    { pre ? "", text ? "", tooltip ? "", alt ? "", class ? "", percentage ? ""
    }:
    "${
      pkgs.writeShellScriptBin "waybar-${name}" ''
        set -euo pipefail
        ${pre}
        ${jq} -cn \
        --arg text "${text}" \
        --arg tooltip "${tooltip}" \
        --arg alt "${alt}" \
        --arg class "${class}" \
        --arg percentage "${percentage}" \
        '{text:$text,tooltip:$tooltip,alt:$alt,class:$class,percentage:$percentage}'
      ''
    }/bin/waybar-${name}";
in {
  programs.waybar = {
    enable = true;
    #package = inputs.waybar.packages.${pkgs.system}.waybar;

    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };

    settings = {
      primary = {
        layer = "top";
        height = 15;
        margin = "5 5 0 5";
        position = "top";

        modules-left = [
          "pulseaudio"
          "battery"
          "custom/mail"
          "custom/task"
          #"custom/vpn"
          #"hyprland/workspaces"
        ];
        modules-center = [
          "custom/player"
        ];
        modules-right = [
          "tray"
          "hyprland/language"
          "custom/appointments"
          "clock"
        ];

        "hyprland/workspaces" = {
          active-only = true;
          all-outputs = true;
          sort-by = "id";
        };

        clock = {
          interval = 1;
          format = "{:%d.%m %H:%M}";
          tooltip-format = ''
            <tt><small>{calendar}</small></tt>
          '';
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            weeks-pos = "left";
            on-scroll = 1;
            format = let inherit (config.colorscheme) colors;
            in {
              months = "<span color='#${colors.base05}'><b>{}</b></span>";
              days = "<span color='#${colors.base05}'>{}</span>";
              weeks = "<span color='#${colors.base0D}'><b>{}</b></span>";
              weekdays = "<span color='#${colors.base0B}'><b>{}</b></span>";
              today = "<span color='#${colors.base0F}'><b>{}</b></span>";
            };
          };

          on-click = "${alacritty} --class khal -e ${khal} -- interactive";

          actions = {
            on-click-right = "mode";
            on-click-forward = "tz_up";
            on-click-backward = "tz_down";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };

        "hyprland/language" = {
          format = "󰌌 {short} {variant}";
          #on-click = "${hyprctl} ${switchxkblayout}";
        };

        pulseaudio = {
          format = "{icon} {volume}";
          format-muted = " 0";
          on-click = pavucontrol;
          format-icons = {
            default = [ "" "" "" ];
          };
        };

        "custom/player" = {
          interval = 2;
          exec-if = "${playerctl} status 2>/dev/null";
          exec = ''${playerctl} metadata --format '{"text": "{{artist}} - {{title}}", "alt": "{{status}}", "tooltip": "{{artist}} - {{title}} ({{album}})"}' '';
          return-type = "json";
          max-lenght = 50;
          format = "{icon} {}";
          format-icons = {
            "Playing" = "󰐊";
            "Paused" = "󰏤";
            "Stopped" = "󰓛";
          };
          on-click = "${playerctl} play-pause";
          #on-click = "${alacritty} --class sptlrx -e ${sptlrx}";
        };

        mpd = {
          interval = 1;
          format = "{artist} - {title}";
          #on-click = "${alacritty} --class ncmpcpp -e ${ncmpcpp}";
          on-click = "${alacritty} --class sptlrx -e ${sptlrx}";
          format-stopped = "";
          format-disconnected = "";
        };

        battery = {
          interval = 60;
          format = "{icon} {capacity}";
          format-charging = "󰂄 {capacity}";
          on-click = "";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        };

        tray = {
          icon-size = 12;
          spacing = 5;
        };

        "custom/mail" = {
          interval = 1;
          format = "{}";
          return-type = "json";
          exec = jsonOutput "new-mails" {
            pre = let
              inherit (builtins) concatStringsSep attrValues filter;
              email_accounts = filter (acc: acc.mbsync.enable)
                (attrValues config.accounts.email.accounts);
            in ''
              total_count=$(${find} ${config.home.homeDirectory}/var/mail/*/Inbox/new -type f | ${wc} -l)

              ${concatStringsSep "\n" (map (acc: ''
                new_${acc.name}=$(${find} ${config.home.homeDirectory}/var/mail/${acc.name}/Inbox/new -type f | ${wc} -l)
              '') email_accounts)}

              tooltip=$(${printf} "${
                concatStringsSep "" (map (acc: ''
                  <b>${acc.name}:</b> $new_${acc.name}
                '') email_accounts)
              }")

              if ${pgrep} mbsync &>/dev/null; then
                status="syncing"
              else if [ "$total_count" == "0" ]; then
                  status="read"
                else
                  status="unread"
                fi
              fi
            '';
            text = " $total_count";
            tooltip = "$tooltip";
          };
          on-click = "${alacritty} --class neomutt -e ${neomutt}";
        };

        "custom/appointments" = {
          interval = 60;
          format = "{}";
          return-type = "json";
          exec = jsonOutput "appointments" {
            pre = let inherit (config.colorscheme) colors; in ''
              filter='-a peasec -a audacis-philipp'

              next_time=$(${khal} list $filter now 1d --format "{start-time}" --day-format "" --notstarted | ${head} -n 1)
              upcoming=$(${khal} list now eod --format "{start-time}" --day-format "" --notstarted)
              today_tooltip=$(${khal} list today eod --format '{start} {title}' --day-format '<span color="#${colors.base0F}"><b>{name}, {date}</b></span>')
              tomorrow_tooltip=$(${khal} list tomorrow eod --format '{start} {title}' --day-format '<span color="#${colors.base0B}"><b>{name}, {date}</b></span>')

              if [ -z $upcoming ]; then tooltip=$tomorrow_tooltip; else tooltip=$today_tooltip; fi
              tooltip=$(${printf} "$today_tooltip\n\n$tomorrow_tooltip")

              if [ -z $next_time ]; then text="None"; else text=$next_time; fi
            '';

            text = "󰃭 $text";
            tooltip = "$tooltip";
          };
          on-click = "${alacritty} --class khal -e ${khal} -- interactive";
        };

        "custom/task" = {
          interval = 1;
          format = "{}";
          return-type = "json";
          exec = jsonOutput "task" {
            pre = let
              inherit (config.colorscheme) colors;
              inherit (builtins) concatStringsSep;
            in ''
              overdue="$(${task} +OVERDUE count)"
              due="$(${task} +DUE count)"
              today="$(${task} +OVERDUE or +TODAY count)"

              tooltip=$(${printf} "${concatStringsSep "\n" [
                "<b>Today:</b> $today"
                ""
                "<b>Total</b>"
                "<span color='#${colors.base0F}'><b>Overdue:</b></span> $overdue"
                "<span color='#${colors.base0B}'><b>Due:</b></span> $due"
                "<b>Tasks:</b> $(${task} +PENDING count)"
              ]}")
            '';
            text = " $today";
            tooltip = "$tooltip";
          };
          on-click = "${pkill} -USR2 waybar";
        };
      };
    };

    # Cheatsheet:
    # x -> all sides
    # x y -> vertical, horizontal
    # x y z -> top, horizontal, bottom
    # w x y z -> top, right, bottom, left
    style = let
      inherit (config.colorscheme) colors;
      # css
    in ''
      * {
        border: none;
        border-radius: 5px;

        font-family: "Share Tech Mono";
        font-size: 12pt;

        padding: 0 10px;
        margin: 0 3px;

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

      #battery, #language, #custom-appointments {
        background: #${colors.base08};
      }
      
      /* blue */
      #custom-vpn {
        background: #${colors.base0A};
      }

      /* green */
      #custom-task {
        background: #${colors.base0E};
      }

      /* green */
      #custom-mail, #tray, #mpd, #custom-player  {
        background: #${colors.base0C};
      }

      /* red */
      #battery.discharging.critical {
        background: #${colors.base0F};
      }

      #mpd.disconnected,
      #mpd.stopped {
        color: transparent;
        background: transparent;
      }
    '';
  };
}
