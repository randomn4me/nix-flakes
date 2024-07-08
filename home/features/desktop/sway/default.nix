{ pkgs, config, ... }:
{
  imports = [
    ../common
    ../common/wayland-wm

    ./tty-init.nix
    ./basic-binds.nix
    ./windowrules.nix
  ];

  home.packages = with pkgs; [ sway-contrib.grimshot ];

  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;

    config = rec {
      modifier = "Mod1";

      input = {
        "type:keyboard" = {
          xkb_capslock = "disabled";
          xkb_layout = "de";
        };
        "type:touchpad" = {
          natural_scroll = "enabled";
          tap = "enabled";
        };
      };

      window = {
        border = 1;
        titlebar = false;
      };

      gaps.smartBorders = "on";

      output.eDP-1.scale = "1.5";

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

      defaultWorkspace = "workspace number 1";

      keybindings =
        let
          grimshot = "${pkgs.sway-contrib.grimshot}/bin/grimshot";
          wpctl = "${pkgs.wireplumber}/bin/wpctl";
          makoctl = "${config.services.mako.package}/bin/makoctl";
          playerctl = "${config.services.playerctld.package}/bin/playerctl";

          light = "${pkgs.light}/bin/light";
          swaylock = "${config.programs.swaylock.package}/bin/swaylock";
          rofi-rbw = "${pkgs.rofi-rbw}/bin/rofi-rbw";
          wofi-emoji = "${pkgs.wofi-emoji}/bin/wofi-emoji";
        in
        {
          "${modifier}+Return" = "exec ${config.wayland.windowManager.sway.config.terminal}";
          "${modifier}+Shift+s" = "exec ${grimshot} --notify copy area";

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

          "${modifier}+w" = "exec ${makoctl} dismiss";

          "${modifier}+space" = "exec --no-startup-id wofi --show drun";
          "${modifier}+Shift+q" = "exec --no-startup-id shutdown-menu";
          "${modifier}+p" = "exec paper-menu";
          "${modifier}+o" = "exec ${wofi-emoji} -t";
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
