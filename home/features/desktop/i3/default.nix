{ pkgs, config, ... }: {
  imports = [
    ../common
    ../common/x11-wm
  ];

  xsession.enable = true;
  xsession.windowManager.i3 = {
    enable = true;

    config = rec {
      modifier = "Mod1";
      bars = [
        {
          position = "bottom";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml";
          fonts = [ "ShureTechMono Nerd Font Propo 12" ];
        }
      ];

      window = {
        border = 1;
        titlebar = false;
      };

      keybindings = let
        terminal = config.home.sessionVariables.TERMINAL;

        pamixer = "${pkgs.pamixer}/bin/pamixer";
        wpctl = "${pkgs.wireplumber}/bin/wpctl";
        dunstctl = "${config.services.dunst.package}/bin/dunstctl";
        playerctl = "${config.services.playerctld.package}/bin/playerctl";

        light = "${pkgs.light}/bin/light";
        dmenu_run = "${pkgs.dmenu}/bin/dmenu_run";
      in {
        XF86AudioRaiseVolume = "exec ${wpctl} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
        XF86AudioLowerVolume = "exec ${wpctl} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-";
        XF86AudioMute =        "exec ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
        XF86AudioMicMute =     "exec ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

        XF86AudioNext = "exec ${playerctl} next";
        XF86AudioPrev = "exec ${playerctl} previous";
        XF86AudioPlay = "exec ${playerctl} play-pause";
        XF86AudioStop = "exec ${playerctl} stop";

        XF86MonBrightnessUp = "exec ${light} -A 4";
        XF86MonBrightnessDown = "exec ${light} -U 4";

        "${modifier}+Return" = "exec --no-startup-id ${terminal}";

        "${modifier}+q" = "kill";
        "${modifier}+w" = "${dunstctl} close";

        "${modifier}+space" = "exec --no-startup-id ${dmenu_run}";

        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";

        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+l" = "move right";

        "${modifier}+Shift+e" = "split toggle";
        "${modifier}+Shift+f" = "fullscreen toggle";
        "${modifier}+Shift+space" = "fullscreen toggle";

        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";

        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";
      };

      assigns = {
          "2" = [ { class = "^firefox$"; } ];
          "3" = [ { class = "zotero"; } { class = "obsidian"; } { class = "libreoffice"; } ];
          "4" = [ { class = "Signal"; } ];
          "6" = [ { class = "zoom"; } ];
      };

      startup = let
        i3-msg = "${pkgs.i3}/bin/i3-msg";
      in [
        {
          command = "exec ${i3-msg} workspace 1";
          always = true;
          notification = false;
        }
      ];
    };
  };

  programs.i3status-rust = let 
    head = "${pkgs.coreutils}/bin/head";
    jq = "${pkgs.jq}/bin/jq";
    khal = "${pkgs.khal}/bin/khal";

    jsonOutput = name:
      { pre ? "", icon ? "", state ? "", text ? "required", short_text ? "" }:
      "${
        pkgs.writeShellScriptBin "i3status-rust-${name}" ''
          set -euo pipefail
          ${pre}
          ${jq} -cn \
          --arg icon "${icon}" \
          --arg state "${state}" \
          --arg text "${text}" \
          --arg short_text "${short_text}" \
          '{icon:$icon,state:$state,text:$text,short_text:$short_text}'
        ''
      }/bin/i3status-rust-${name}";
  in {
    enable = true;

    bars = {
      default = {
        icons = "awesome6";
        theme = "space-villain";

        blocks = [
          {
            block = "taskwarrior";
            interval = 30;
            data_location = config.programs.taskwarrior.dataLocation;
            filters = [
            {
              name = "today";
              filter = "+PENDING +OVERDUE or +DUETODAY";
            }
            ];
          }

          {
            block = "maildir";
            interval = 2;
            inboxes = [ "${config.accounts.email.maildirBasePath}/*/*" ];
            threshold_warning = 1;
            threshold_critical = 10;
            display_type = "new";
          }

          {
            block = "custom";
            interval = 60;
            command = jsonOutput "appointments" {
              pre = ''
                filter='-a peasec -a audacis-philipp'

                text=$(${khal} list $filter now 1d --format "{start-time}" --day-format "" --notstarted | ${head} -n 1)
                short_text=$(${khal} list $filter now 1d --format "{start-time} {title}" --day-format "" --notstarted | ${head} -n 1)
                '';
              icon = "calendar";
              state = "Good";
              text = "$text";
              short_text = "$short_text";
            };
            json = true;
            hide_when_empty = true;
          }

          {
            block = "sound";
            max_vol = 100;
            click = [
            {
              button = "left";
              cmd = let pavu = "${pkgs.pavucontrol}/bin/pavucontrol"; in "${pavu}";
            }
            ];
          }

          {
            block = "battery";
            device = "BAT0";
            interval = 30;
            full_format = " $icon $percentage ";
          }

          {
            block = "time";
            interval = 10;
            format = " $timestamp.datetime(f:'%d.%m %R') ";
          }
        ];
      };
    };
  };
}
