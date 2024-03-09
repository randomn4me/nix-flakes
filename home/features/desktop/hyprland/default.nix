{ lib, config, pkgs, inputs, ... }:

{
  imports = [
    ../common
    ../common/wayland-wm

    ./tty-init.nix
    ./basic-binds.nix
    ./windowrule.nix
    #./systemd-fixes.nix
  ];

  home.packages = [
    inputs.hyprwm-contrib.packages.${pkgs.system}.grimblast
    inputs.hyprpicker.packages.${pkgs.system}.hyprpicker
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;

    systemd.enable = true;

    settings = {
      general = {
        gaps_in = 0;
        gaps_out = 0;
        cursor_inactive_timeout = 2;
        "col.active_border" = "0xff${config.colorscheme.colors.base09}";
        "col.inactive_border" = "0xff${config.colorscheme.colors.base03}";
      };

      binds.allow_workspace_cycles = true;

      input = {
        #kb_layout = "de";
        kb_layout = "de,de";
        kb_variant = ",bone";
        kb_options = "grp:ctrl_space_toggle";

        touchpad.natural_scroll = true;

        sensitivity = 0;
      };

      decoration.rounding = 0;
      decoration.blur.enabled = false;
      decoration.drop_shadow = false;
      animations.enabled = false;

      misc = {
        force_default_wallpaper = 0;
      };

      exec = [ "${pkgs.swaybg}/bin/swaybg -i ${config.wallpaper} --mode fill" ];

      bind = let
        swaylock = "${config.programs.swaylock.package}/bin/swaylock";
        playerctl = "${config.services.playerctld.package}/bin/playerctl";
        makoctl = "${config.services.mako.package}/bin/makoctl";
        bemenu-run = "${config.programs.bemenu.package}/bin/bemenu-run";

        grimblast = "${inputs.hyprwm-contrib.packages.${pkgs.system}.grimblast}/bin/grimblast";

        rofi-rbw = "${pkgs.rofi-rbw}/bin/rofi-rbw";

        terminal = config.home.sessionVariables.TERMINAL;
      in [
        "ALT,Return,exec,${terminal}"

        "ALT SHIFT,s,exec,${grimblast} --notify --freeze copy area"
      ] ++

      (lib.optionals config.services.playerctld.enable [
        # Media control
        ",XF86AudioNext,exec,${playerctl} next"
        ",XF86AudioPrev,exec,${playerctl} previous"
        ",XF86AudioPlay,exec,${playerctl} play-pause"
        ",XF86AudioStop,exec,${playerctl} stop"
      ]) ++

      # Screen lock
      (lib.optionals config.programs.swaylock.enable
        [ "CTRL ALT,l,exec,${swaylock}" ]) ++

      # Notification manager
      (lib.optionals config.services.mako.enable
        [ "ALT,w,exec,${makoctl} dismiss" ]) ++

      # Launcher
      (lib.optionals config.programs.bemenu.enable [
        "ALT,SPACE,exec,${bemenu-run}"
        "ALT,p,exec,paper-menu"
        "ALT SHIFT,p,exec,${rofi-rbw}"
        "ALT SHIFT,q,exec,shutdown-menu"
      ]);

      binde = let
        light = "${pkgs.light}/bin/light";
        wpctl = "${pkgs.wireplumber}/bin/wpctl";
      in [
        ",XF86MonBrightnessUp,exec,${light} -A 5"
        ",XF86MonBrightnessDown,exec,${light} -U 5"

        ",XF86AudioRaiseVolume,exec,${wpctl} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,exec,${wpctl} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute,exec,${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
        "SHIFT,XF86AudioMute,exec,${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86AudioMicMute,exec,${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ];

      bindl = let
        hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";

        m = builtins.head config.monitors;
      in if m != [] && m.name == "eDP-1" && m.enabled then let
        res = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
        position = "${toString m.x}x${toString m.y}";
        command = "${hyprctl} keyword monitor";
        scaling = "${toString m.scaling}";
      in
        [
          ",switch:off:Lid Switch,exec,${command} '${m.name},${res},${position},${scaling}'"
          ",switch:on:Lid Switch,exec,${command} '${m.name}, disable'"
        ]
      else [];

      monitor = map (m: let
        resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
        position = "${toString m.x}x${toString m.y}";
        scaling = "${toString m.scaling}";
      in
        "${m.name},${if m.enabled then "${resolution},${position},${scaling}" else "disable"}"
      ) (config.monitors)
      ++ [
        ", preferred, auto, 1"
      ];

      workspace = lib.lists.flatten (map (m: 
        map (w: 
          "${toString w},monitor:${m.name},default:true")
        m.workspaces)
      (lib.filter (m: m.enabled && m.workspaces != null) config.monitors));

    };

    extraConfig = ''
      bind=ALT,R,submap,resize

      submap=resize
        binde=,h,resizeactive,-20 0
        binde=,j,resizeactive,0 20
        binde=,k,resizeactive,0 -20
        binde=,l,resizeactive,20 0
        bind=,escape,submap,reset 
      submap=reset
    '';
  };
}
