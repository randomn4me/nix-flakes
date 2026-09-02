{ config, pkgs, ... }:

let
  terminal-string = config.home.sessionVariables.TERMINAL;
  terminal = "${config.programs.${terminal-string}.package}/bin/${terminal-string}";

  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";

  neomutt = "${config.programs.neomutt.package}/bin/neomutt";
  task = "${config.programs.taskwarrior.package}/bin/task";

  cat = "${pkgs.coreutils}/bin/cat";
  head = "${pkgs.coreutils}/bin/head";
  printf = "${pkgs.coreutils}/bin/printf";
  wc = "${pkgs.coreutils}/bin/wc";

  sed = "${pkgs.gnused}/bin/sed";
  awk = "${pkgs.gawk}/bin/awk";

  jq = "${pkgs.jq}/bin/jq";
  find = "${pkgs.findutils}/bin/find";

  khal = "${pkgs.khal}/bin/khal";
  playerctl = "${pkgs.playerctl}/bin/playerctl";

  # playerctl --follow blocks until the player state actually changes, so the
  # module costs nothing while idle instead of forking playerctl once a second.
  # It emits an empty line when the last player goes away; waybar wants valid
  # JSON on every line, hence the {} substitution.
  playerFollow = pkgs.writeShellScript "waybar-player" ''
    ${playerctl} --follow metadata --format \
      '{"text": "{{artist}} - {{title}}", "alt": "{{status}}", "tooltip": "{{artist}} - {{title}} ({{album}})"}' \
      2>/dev/null | while IFS= read -r line; do
        if [ -z "$line" ]; then echo '{}'; else echo "$line"; fi
      done
  '';

  # RTMIN+8: sent by the mbsync unit (home/features/accounts/mbsync.nix) so the
  # counter updates on sync rather than by re-walking the maildirs on a timer.
  mailSignal = 8;

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
          "hyprland/workspaces"
        ];

        modules-center = [ "custom/player" ];

        modules-right = [
          "custom/task"
          "custom/mail"
          "custom/appointments"
          "wireplumber"
          "custom/power"
          "battery"
          "clock"
        ];

        "hyprland/workspaces" = {
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
                colors = config.colorscheme.palette;
              in
              {
                months = "<span color='#${colors.base05}'><b>{}</b></span>";
                days = "<span color='#${colors.base05}'>{}</span>";
                weeks = "<span color='#${colors.base0D}'><b>{}</b></span>";
                weekdays = "<span color='#${colors.base0B}'><b>{}</b></span>";
                today = "<span color='#${colors.base0F}'><b>{}</b></span>";
              };
          };

          on-click = "${terminal} --class=com.mitchellh.ghostty.khal -e ${khal} -- interactive";

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
          # Updates are event-driven over the mpd idle protocol; this interval
          # only governs how often a lost connection is retried.
          interval = 10;
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
          # Walking every maildir every 5s was the busiest thing on an
          # otherwise idle bar. The signal carries the actual updates; the
          # interval is only a safety net for mail arriving by other means.
          interval = 300;
          signal = mailSignal;
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
          on-click = "${terminal} --class=com.mitchellh.ghostty.neomutt -e ${neomutt}";
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
          on-click = "${terminal} --class=com.mitchellh.ghostty.khal -e ${khal} -- interactive";
        };

        "custom/task" = {
          interval = 15;
          format = "{}";
          return-type = "json";
          exec = jsonOutput "task" {
            pre =
              let
                colors = config.colorscheme.palette;
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

        "custom/power" = {
          interval = 30;
          format = "{}";
          return-type = "json";
          exec = jsonOutput "power" {
            pre = ''
              watts=""
              status=""
              for bat in /sys/class/power_supply/BAT*; do
                [ -r "$bat/power_now" ] || continue
                watts=$(${awk} -v uw="$(${cat} "$bat/power_now")" \
                  'BEGIN { printf "%.1f", uw / 1000000 }')
                status=$(${cat} "$bat/status" 2>/dev/null || echo Unknown)
                break
              done

              if [ -n "$watts" ]; then text="󱐋 $watts W"; else text=""; fi
            '';
            text = "$text";
            tooltip = "$status: $watts W";
          };
        };

        "custom/player" = {
          return-type = "json";
          exec = "${playerFollow}";
          restart-interval = 5;
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
        colors = config.colorscheme.palette;
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
        #custom-power,
        #battery,
        #clock {
          padding: 0 10px;
        }
      '';
  };
}
