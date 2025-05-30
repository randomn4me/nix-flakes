{ config, pkgs, ... }:

let
  terminal-string = config.home.sessionVariables.TERMINAL;
  terminal = "${config.programs.${terminal-string}.package}/bin/${terminal-string}";

  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";

  neomutt = "${config.programs.neomutt.package}/bin/neomutt";
  task = "${config.programs.taskwarrior.package}/bin/task";

  head = "${pkgs.coreutils}/bin/head";
  printf = "${pkgs.coreutils}/bin/printf";
  wc = "${pkgs.coreutils}/bin/wc";

  sed = "${pkgs.gnused}/bin/sed";

  jq = "${pkgs.jq}/bin/jq";
  find = "${pkgs.findutils}/bin/find";

  khal = "${pkgs.khal}/bin/khal";
  playerctl = "${pkgs.playerctl}/bin/playerctl";

  # Function to simplify making waybar outputs
  jsonOutput =
    name:
    {
      pre ? "",
      text ? "",
      tooltip ? "",
      alt ? "",
      class ? "",
      percentage ? "",
    }:
    "${pkgs.writeShellScriptBin "waybar-${name}" ''
      set -euo pipefail
      ${pre}
      ${jq} -cn \
      --arg text "${text}" \
      --arg tooltip "${tooltip}" \
      --arg alt "${alt}" \
      --arg class "${class}" \
      --arg percentage "${percentage}" \
      '{text:$text,tooltip:$tooltip,alt:$alt,class:$class,percentage:$percentage}'
    ''}/bin/waybar-${name}";
in
{
  programs.waybar = {
    enable = true;

    systemd = {
      enable = true;
    };

    settings = {
      primary = {
        layer = "top";
        position = "bottom";
        reload_style_on_change = true;

        modules-left = [
          "tray"
          "sway/workspaces"
        ];

        modules-center = [ "custom/player" ];

        modules-right = [
          "custom/task"
          "custom/mail"
          "custom/appointments"
          "wireplumber"
          "battery"
          "clock"
        ];

        "sway/workspaces" = {
          all-outputs = true;
          sort-by = "id";
          format = "{name}";
        };

        clock = {
          interval = 15;
          format = "{:%d.%m %H:%M}";
          tooltip-format = ''
            <tt>{calendar}</tt>
          '';
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            weeks-pos = "left";
            on-scroll = 1;
            format =
              let
                inherit (config.colorscheme) colors;
              in
              {
                months = "<span color='#${colors.base05}'><b>{}</b></span>";
                days = "<span color='#${colors.base05}'>{}</span>";
                weeks = "<span color='#${colors.base0D}'><b>{}</b></span>";
                weekdays = "<span color='#${colors.base0B}'><b>{}</b></span>";
                today = "<span color='#${colors.base0F}'><b>{}</b></span>";
              };
          };

          on-click = "${terminal} --app-id khal ${khal} -- interactive";

          actions = {
            on-click-right = "mode";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };

        wireplumber = {
          format = "{icon} {volume}";
          format-muted = " 0";
          on-click = pavucontrol;
          format-icons = {
            default = [
              ""
              ""
              ""
            ];
          };
        };

        mpd = {
          interval = 1;
          format = "{stateIcon} {artist} - {title}";
          format-stopped = "";
          format-disconnected = "";
          state-icons = {
            playing = "󰐊";
            paused = "󰏤";
          };
        };

        battery = {
          interval = 60;
          format = "{icon} {capacity}";
          format-charging = "󰂄 {capacity}";
          on-click = "";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
        };

        tray = {
          icon-size = 12;
          spacing = 8;
        };

        "custom/mail" = {
          interval = 5;
          format = "{}";
          return-type = "json";
          exec = jsonOutput "new-mails" {
            pre =
              let
                inherit (builtins) concatStringsSep attrValues filter;
                email_accounts = filter (acc: acc.mbsync.enable) (attrValues config.accounts.email.accounts);
              in
              ''
                total_count=$(${find} ${config.home.homeDirectory}/var/mail/*/Inbox/new -type f | ${wc} -l)

                ${concatStringsSep "\n" (
                  map (acc: ''
                    new_${acc.name}=$(${find} ${config.home.homeDirectory}/var/mail/${acc.name}/Inbox/new -type f | ${wc} -l)
                  '') email_accounts
                )}

                tooltip=$(${printf} "${
                  concatStringsSep "" (
                    map (acc: ''
                      ${acc.name}: $new_${acc.name}
                    '') email_accounts
                  )
                }")
              '';
            text = " $total_count";
            tooltip = "$tooltip";
          };
          on-click = "${terminal} --app-id neomutt ${neomutt}";
        };

        "custom/appointments" = {
          interval = 120;
          format = "{}";
          return-type = "json";
          exec = jsonOutput "appointments" {
            pre = ''
              filter='-a peasec -a audacis-philipp'

              next_appointment=$(${khal} list $filter now 1d --format "{start-time}" --day-format "" --notstarted | ${sed} '/^$/d' | ${head} -n 1)
              upcoming=$(${khal} list now eod --format "{start-time}" --day-format "" --notstarted)
              today_tooltip=$(${khal} list today eod --format '{start} {title}' --day-format '<b>{name}, {date}</b>')
              tomorrow_tooltip=$(${khal} list tomorrow eod --format '{start} {title}' --day-format '<b>{name}, {date}</b>')
              tooltip=$(${printf} "$today_tooltip\n\n$tomorrow_tooltip")

              if [ -z $next_appointment ]; then text="None"; else text="$next_appointment" ; fi
            '';

            text = "󰃭 $text";
            tooltip = "$tooltip";
          };
          on-click = "${terminal} --app-id khal ${khal} -- interactive";
        };

        "custom/task" = {
          interval = 15;
          format = "{}";
          return-type = "json";
          exec = jsonOutput "task" {
            pre =
              let
                inherit (config.colorscheme) colors;
                inherit (builtins) concatStringsSep;
              in
              ''
                overdue="$(${task} +OVERDUE count)"
                due="$(${task} +DUE count)"
                today="$(${task} +OVERDUE or +TODAY count)"

                tooltip=$(${printf} "${
                  concatStringsSep "\n" [
                    "<b>Today:</b> $today"
                    ""
                    "<b>Total</b>"
                    "<span color='#${colors.base0F}'>Overdue:</span> $overdue"
                    "<span color='#${colors.base0B}'>Due:</span> $due"
                    "Tasks: $(${task} +PENDING count)"
                  ]
                }")
              '';
            text = " $today";
            tooltip = "$tooltip";
          };
        };

        "custom/player" = {
          interval = 1;
          return-type = "json";
          exec-if = "${playerctl} status 2>/dev/null";
          exec = ''${playerctl} metadata --format '{"text": "{{artist}} - {{title}}", "alt": "{{status}}", "tooltip": "{{artist}} - {{title}} ({{album}})"}' 2>/dev/null '';
          max-length = 60;
          format = "{icon} {}";
          format-icons = {
            "Playing" = "󰐊";
            "Paused" = "󰏤";
            "Stopped" = "󰓛";
          };
          on-click = "${playerctl} play-pause";
        };
      };
    };

    # Cheatsheet:
    # x -> all sides
    # x y -> vertical, horizontal
    # x y z -> top, horizontal, bottom
    # w x y z -> top, right, bottom, left
    style =
      let
        inherit (config.colorscheme) colors;
      in
      # css
      ''
        * {
          border: none;

          font-family: "ShureTechMono Nerd Font Propo";
          font-size: 12pt;
        }

        tooltip,
        window#waybar {
          background: #000000;
          color: #${colors.base05};
        }


        tooltip {
          border: 1px solid #${colors.base09};
        }

        tooltip label {
          color: #${colors.base05};
        }

        #workspaces button {
          padding: 0 2px;

          color: #${colors.base04};
        }

        #workspaces button:hover {
          box-shadow: inherit;
          text-shadow: inherit;
        }

        #workspaces button.active {
          font-weight: bold;
          background: #${colors.base02};
          color: #${colors.base05};
        }

        #workspaces button.urgent {
          font-weight: bold;
          background: #B1252E;
          color: #${colors.base05};
        }

        #tray,
        #custom-task,
        #custom-mail,
        #custom-appointments,
        #wireplumber,
        #battery,
        #clock {
          padding: 0 10px;
        }
      '';
  };
}
