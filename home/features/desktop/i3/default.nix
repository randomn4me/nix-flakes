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
      bars = [ ];

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
        rofi = "${pkgs.rofi}/bin/rofi";
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
        "${modifier}+Space" = "exec ${rofi} -modi drun -show drun";
      };

      startup = let
        i3-msg = "${pkgs.i3}/bin/i3-msg";
        hsetroot = "${pkgs.hsetroot}/bin/hsetroot";
      in [
        {
          command = "exec ${i3-msg} workspace 1";
          always = true;
          notification = false;
        }
        {
          command = "${hsetroot} -fill ${config.wallpaper}";
          always = true;
          notification = false;
        }
      ];
    };
  };
}

