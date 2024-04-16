{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ../common
    ../common/wayland-wm

    ./tty-init.nix
    ./basic-binds.nix
    ./windowrules.nix
  ];

  home.packages = [ inputs.hyprwm-contrib.packages.${pkgs.system}.grimblast ];

  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;

    config = rec {
      modifier = "Mod1";

      input = {
        "*".xkb_layout = "de";
      };

      window = {
        border = 1;
        titlebar = false;
      };

      output.eDP-1.scale = "1.333333";

      bars = [ ];

      startup = [
        {
          command = "systemctl --user restart waybar";
          always = true;
        }
        {
          command = "${pkgs.swaybg}/bin/swaybg -i ${config.wallpaper} --mode fill";
          always = true;
        }
      ];

      colors =
        let
          setBorder = borderColor: {
            background = "#000000";
            border = "${borderColor}";
            childBorder = "${borderColor}";
            indicator = "#${config.colorscheme.colors.base0E}";
            text = "#888888";
          };
        in
        {
          focused = setBorder "#${config.colorscheme.colors.base09}";
          unfocused = setBorder "#${config.colorscheme.colors.base03}";
          urgent = setBorder "#B1252E";
        };

      defaultWorkspace = "workspace number 1";

      keybindings =
        let
          grimblast = "${inputs.hyprwm-contrib.packages.${pkgs.system}.grimblast}/bin/grimblast";
          wpctl = "${pkgs.wireplumber}/bin/wpctl";
          makoctl = "${config.services.mako.package}/bin/makoctl";
          playerctl = "${config.services.playerctld.package}/bin/playerctl";

          light = "${pkgs.light}/bin/light";
          swaylock = "${config.programs.swaylock.package}/bin/swaylock";
          rofi-rbw = "${pkgs.rofi-rbw}/bin/rofi-rbw";
        in
        {
          "${modifier}+Shift+s" = "exec ${grimblast} --notify --freeze copy area";

          "${modifier}+Tab" = "workspace back_and_forth";

          "XF86AudioRaiseVolume" = "exec ${wpctl} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume" = "exec ${wpctl} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute" = "exec ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioMicMute" = "exec ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

          "XF86AudioNext" = "exec ${playerctl} next";
          "XF86AudioPrev" = "exec ${playerctl} previous";
          "XF86AudioPlay" = "exec ${playerctl} play-pause";
          "XF86AudioStop" = "exec ${playerctl} stop";

          "XF86MonBrightnessUp" = "exec ${light} -A 4";
          "XF86MonBrightnessDown" = "exec ${light} -U 4";

          "${modifier}+w" = "${makoctl} dismiss";

          "${modifier}+space" = "exec --no-startup-id wofi --show drun";
          "${modifier}+Shift+q" = "exec --no-startup-id shutdown-menu";
          "${modifier}+p" = "exec paper-menu";
          "${modifier}+SHIFT+p" = "exec ${rofi-rbw}";

          "${modifier}+Ctrl+l" = "exec --no-startup-id ${swaylock}";
        };
    };

    extraConfig = ''
      set $laptop eDP-1
      bindswitch --reload --locked lid:on output $laptop disable
      bindswitch --reload --locked lid:off output $laptop enable
    '';
  };
}
