{ pkgs, config, ... }: {
  imports = [
    ../common
    ../common/x11-wm

    #./basic-binds.nix
    #./windowrules.nix
  ];

  xsession.enable = true;
  xsession.windowManager.i3 = {
    enable = true;

    config = rec {
      modifier = "Alt";
      bars = [
        {
          position = "bottom";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-bottom.toml";
        }
      ];

      window = {
        border = 2;
        titlebar = false;
      };

      gaps = {
        inner = 5;
        outer = 5;
      };

      keybindings = let
        terminal = config.home.sessionVariables.TERMINAL;

        pamixer = "${pkgs.pamixer}/bin/pamixer";
        pactl = "${pkgs.pulseaudio}/bin/pactl";
        playerctl = "${config.services.playerctld.package}/bin/playerctl";

        light = "${pkgs.light}/bin/light";
        dmenu_run = "${pkgs.dmenu}/bin/dmenu_run";
      in {
        XF86AudioRaiseVolume = "exec ${pamixer} -i 5";
        XF86AudioLowerVolume = "exec,${pamixer} -d 5";
        XF86AudioMute = "exec ${pamixer} -t";
        XF86AudioMicMute =
          "exec ${pactl} set-source-mute @DEFAULT_SOURCE@ toggle";

        XF86AudioNext = "exec ${playerctl} next";
        XF86AudioPrev = "exec ${playerctl} previous";
        XF86AudioPlay = "exec ${playerctl} play-pause";
        XF86AudioStop = "exec ${playerctl} stop";

        XF86MonBrightnessUp = "exec ${light} -A 4";
        XF86MonBrightnessDown = "exec ${light} -U 4";

        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+Space" = "exec ${dmenu_run}";
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
        pkgs.writeShellScriptBin "waybar-${name}" ''
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
      bottom = {
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

                      next_time=$(${khal} list $filter now 1d --format "{start-time}" --day-format "" --notstarted | ${head} -n 1)
                      short_text=$(${khal} list $filter now 1d --format "{start-time} {title}" --day-format "" --notstarted | ${head} -n 1)
                      '';
                  icon = "calendar-day";
                  text = "$text";
                  short_text = "$short_text";
              };
              json = true;
              hide_when_emtpy = true;
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

        icons = "awesome6";
        theme = "space-villain";
      };
    };
  };
}
