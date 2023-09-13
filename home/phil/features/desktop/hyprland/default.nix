{ lib, config, inputs, pkgs, ... }:

{
  imports = [
    #inputs.hyprland.homeManagerModules.default
    ../common
    ../common/wayland-wm

    ./tty-init.nix
    ./basic-binds.nix
    ./systemd-fixes.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    #package = inputs.hyprland.packages.${pkgs.system}.hyprland;

    settings = {
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        cursor_inactive_timeout = 4;
        "col.active_border" = "0xff${config.colorscheme.colors.base09}";
        "col.inactive_border" = "0xff${config.colorscheme.colors.base03}";
      };
      input = {
        kb_layout = "de";
        #kb_layout = "de,de";
        #kb_variant = ",bone";
        #kb_options = "grp:ctrl_space_toggle";

        follow_mouse = true;

        touchpad = {
          disable_while_typing = false;
          natural_scroll = true;
        };

        sensitivity = 0;
      };

      decoration = {
        active_opacity = 0.94;
        inactive_opacity = 0.84;
        rounding = 5;

        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
        };

        drop_shadow = true;
        shadow_range = 12;
        shadow_offset = "3 3";
        "col.shadow" = "0x44000000";
        "col.shadow_inactive" = "0x66000000";
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

      #exec = [
      #  "${pkgs.swaybg}/bin/swaybg -i ${config.wallpaper} --mode fill"
      #];

      bind = let
        swaylock = "${config.programs.swaylock.package}/bin/swaylock";
        playerctl = "${config.services.playerctld.package}/bin/playerctl";
        makoctl = "${config.services.mako.package}/bin/makoctl";
        wofi = "${config.programs.wofi.package}/bin/wofi";

        pactl = "${pkgs.pulseaudio}/bin/pactl";
        terminal = config.home.sessionVariables.TERMINAL;
      in [
        # Program bindings
        "SUPER,Return,exec,${terminal}"
        # Brightness control (only works if the system has lightd)
        ",XF86MonBrightnessUp,exec,light -A 10"
        ",XF86MonBrightnessDown,exec,light -U 10"
        # Volume
        ",XF86AudioRaiseVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ +5%"
        ",XF86AudioLowerVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ -5%"
        ",XF86AudioMute,exec,${pactl} set-sink-mute @DEFAULT_SINK@ toggle"
        "SHIFT,XF86AudioMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
        ",XF86AudioMicMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
      ] ++

      (lib.optionals config.services.playerctld.enable [
        # Media control
        ",XF86AudioNext,exec,${playerctl} next"
        ",XF86AudioPrev,exec,${playerctl} previous"
        ",XF86AudioPlay,exec,${playerctl} play-pause"
        ",XF86AudioStop,exec,${playerctl} stop"
        "ALT,XF86AudioPlay,exec,systemctl --user restart playerctld"
      ]) ++
      # Screen lock
      (lib.optionals config.programs.swaylock.enable [
        "SUPER,backspace,exec,${swaylock}"
      ]) ++
      # Notification manager
      (lib.optionals config.services.mako.enable [
        "SUPER,w,exec,${makoctl} dismiss"
      ]) ++

      # Launcher
      (lib.optionals config.programs.wofi.enable [
        #"SUPER,x,exec,${wofi} -S drun -x 10 -y 10 -W 25% -H 60%"
        "SUPER,d,exec,${wofi} -S run"
      ]);

      monitor = map (m: let
        resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
        position = "${toString m.x}x${toString m.y}";
      in
        "${m.name},${if m.enabled then "${resolution},${position},1" else "disable"}"
      ) (config.monitors);

      workspace = map (m:
        "${m.name},${m.workspace}"
      ) (lib.filter (m: m.enabled && m.workspace != null) config.monitors);

    };
  };
}
