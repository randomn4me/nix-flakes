{ pkgs, config, inputs, ... }: {
  imports = [
    ../common
    ../common/x11-wm

    ./i3status-rust.nix
    ./standard-keybindings.nix
    ./windowrules.nix
    ./xinit.nix
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
        inherit (inputs.colorscheme) colors;

        terminal = config.home.sessionVariables.TERMINAL;

        wpctl = "${pkgs.wireplumber}/bin/wpctl";
        dunstctl = "${config.services.dunst.package}/bin/dunstctl";
        playerctl = "${config.services.playerctld.package}/bin/playerctl";

        light = "${pkgs.light}/bin/light";
        i3lock = "${pkgs.i3lock}/bin/i3lock --no-fork -c ${colors.base00}";
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

        "${modifier}+space" = "exec --no-startup-id menu-run";
        "${modifier}+Shift+q" = "exec --no-startup-id shutdown-menu";
        "${modifier}+ctrl+l" = "exec --no-startup-id ${i3lock}";
      };
    };
  };
}
