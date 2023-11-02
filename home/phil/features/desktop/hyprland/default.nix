{ lib, config, pkgs, inputs, ... }:

{
  imports = [
    ../common
    ../common/wayland-wm

    ./tty-init.nix
    ./basic-binds.nix
    ./windowrule.nix
    ./systemd-fixes.nix
  ];

  home.packages = [ inputs.hyprwm-contrib.packages.${pkgs.system}.grimblast ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;

    systemd.enable = true;

    settings = {
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        cursor_inactive_timeout = 4;
        "col.active_border" = "0xff${config.colorscheme.colors.base09}";
        "col.inactive_border" = "0xff${config.colorscheme.colors.base03}";
      };

      binds = { allow_workspace_cycles = true; };

      #xwayland = {
      #  force_zero_scaling = true;
      #};

      input = {
        kb_layout = "de";
        #kb_layout = "de,de";
        #kb_variant = ",bone";
        #kb_options = "grp:ctrl_space_toggle";

        follow_mouse = true;

        touchpad = { natural_scroll = true; };

        sensitivity = 0;
      };

      decoration = {
        #inactive_opacity = 0.75;
        rounding = 5;
      };

      animations = {
        enabled = true;

        bezier = [
          "easein,0.11, 0, 0.5, 0"
          "easeout,0.5, 1, 0.89, 1"
          "easeinback,0.36, 0, 0.66, -0.56"
          "easeoutback,0.34, 1.56, 0.64, 1"
        ];

        animation = [
          "windowsIn,1,3,easeoutback,slide"
          "windowsOut,1,3,easeinback,slide"
          "windowsMove,1,3,easeoutback"
          "workspaces,1,2,easeoutback,slide"
          "fadeIn,1,3,easeout"
          "fadeOut,1,3,easein"
          "fadeSwitch,1,3,easeout"
          "fadeShadow,1,3,easeout"
          "fadeDim,1,3,easeout"
          "border,1,3,easeout"
        ];
      };

      exec = [ "${pkgs.swaybg}/bin/swaybg -i ${config.wallpaper} --mode fill" ];

      misc = { force_default_wallpaper = 0; };

      #exec = [
      #  "${pkgs.swaybg}/bin/swaybg -i ${config.wallpaper} --mode fill"
      #];

      bind = let
        swaylock = "${config.programs.swaylock.package}/bin/swaylock";
        playerctl = "${config.services.playerctld.package}/bin/playerctl";
        makoctl = "${config.services.mako.package}/bin/makoctl";
        wofi = "${config.programs.wofi.package}/bin/wofi";

        grimblast = "${
            inputs.hyprwm-contrib.packages.${pkgs.system}.grimblast
          }/bin/grimblast";

        rofi-rbw = "${pkgs.rofi-rbw}/bin/rofi-rbw";

        terminal = config.home.sessionVariables.TERMINAL;
      in [
        "ALT,Return,exec,${terminal}"

        "ALTSHIFT,s,exec,${grimblast} --notify --freeze copy area"
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
      (lib.optionals config.programs.wofi.enable [
        "ALT,SPACE,exec,${wofi} -S drun"
        "ALT,p,exec,${rofi-rbw}"
        "ALTSHIFT,q,exec,shutdown-menu" # TODO add as package and use here
      ]);

      binde = let
        light = "${pkgs.light}/bin/light";
        pamixer = "${pkgs.pamixer}/bin/pamixer";
        pactl = "${pkgs.pulseaudio}/bin/pactl";
      in [
        ",XF86MonBrightnessUp,exec,${light} -A 5"
        ",XF86MonBrightnessDown,exec,${light} -U 5"

        ",XF86AudioRaiseVolume,exec,${pamixer} -i 5"
        ",XF86AudioLowerVolume,exec,${pamixer} -d 5"
        ",XF86AudioMute,exec,${pamixer} -t"
        "SHIFT,XF86AudioMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
        ",XF86AudioMicMute,exec,  ${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
      ];

      monitor = map (m:
        let
          resolution = "${toString m.width}x${toString m.height}@${
              toString m.refreshRate
            }";
          position = "${toString m.x}x${toString m.y}";
        in "${m.name},${
          if m.enabled then "${resolution},${position},1" else "disable"
        }") (config.monitors);
    };
  };
}
