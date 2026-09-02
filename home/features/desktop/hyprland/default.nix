{
  pkgs,
  lib,
  config,
  ...
}:
let
  colors = config.colorscheme.palette;

  grimblast = "${pkgs.grimblast}/bin/grimblast";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  makoctl = "${config.services.mako.package}/bin/makoctl";
  playerctl = "${config.services.playerctld.package}/bin/playerctl";

  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  ghostty = "${config.programs.ghostty.package}/bin/ghostty";
  hyprlock = "${config.programs.hyprlock.package}/bin/hyprlock";
  rofi-rbw = "${pkgs.rofi-rbw-wayland}/bin/rofi-rbw";
  wofi-emoji = "${pkgs.wofi-emoji}/bin/wofi-emoji";

  hl = import ./lib.nix { inherit lib; };
  inherit (hl)
    mod
    exec
    bind
    bindLocked
    bindLockedRepeat
    ;
in
{
  imports = [
    ../common
    ../common/wayland-wm

    ./basic-binds.nix
    ./windowrules.nix
    ./hyprlock.nix
    ./hypridle.nix
  ];

  home.packages = [ pkgs.grimblast ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;

    # Hyprland 0.56 treats hyprlang (hyprland.conf) as the legacy parser; the
    # Lua config is the current format. Note this also retires `hyprctl
    # keyword` and the bare `hyprctl dispatch <name> <arg>` syntax -- both only
    # work with the legacy parser (see the lid binds below and ./hypridle.nix).
    configType = "lua";

    # Kept on: jameica is Java/SWT and zoom-us still needs an X11 surface.
    # Chromium/Electron go native via NIXOS_OZONE_WL (see ../common/wayland-wm).
    xwayland.enable = true;

    settings = {
      monitor =
        map (m: {
          output = m.name;
          mode = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
          position = "${toString m.x}x${toString m.y}";
          scale = m.scaling;
        }) config.monitors
        # An empty output is Hyprland's catch-all, used only when no other rule
        # matches. Spelling it out keeps an undeclared display predictable --
        # preferred mode, placed to the right -- rather than leaning on whatever
        # the built-in defaults happen to be.
        ++ [
          {
            output = "";
            mode = "preferred";
            position = "auto";
            scale = 1;
          }
        ];

      # Hyprland hands every newly connected monitor the next unclaimed
      # workspace, so plugging in a screen silently moves workspace 2 onto it
      # -- `${mod} + 2` then focuses a display that may well be switched off,
      # which looks like the workspace has vanished. Pinning each declared
      # workspace to its monitor keeps the number keys on the panel they
      # belong to; the first one is that monitor's default.
      workspace_rule = lib.concatMap (
        m:
        lib.imap0 (i: ws: {
          workspace = toString ws;
          monitor = m.name;
          default = i == 0;
        }) (lib.optionals (m.workspaces != null) m.workspaces)
      ) config.monitors;

      config = {
        input = {
          kb_layout = "us,de";
          kb_variant = ",nodeadkeys";
          kb_options = "caps:none,grp:ctrl_space_toggle";
          touchpad = {
            natural_scroll = true;
            # `tap-to-click` in hyprlang; the Lua parser spells config keys
            # with underscores.
            tap_to_click = true;
          };
        };

        general = {
          border_size = 1;
          col = {
            active_border = "rgb(${colors.base09})";
            inactive_border = "rgb(${colors.base03})";
          };
        };

        decoration.rounding = 0;

        # The sway config runs bare (no titlebars, no animation); keep that feel
        # rather than inheriting Hyprland's showier defaults.
        animations.enabled = false;

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };
      };

      bind = [
        (bind "${mod} + Return" (exec ghostty))
        (bind "${mod} + SHIFT + S" (exec "${grimblast} --notify copy area"))

        (bind "${mod} + Tab" ''hl.dsp.focus({ workspace = "previous" })'')

        # With the number keys pinned to one monitor, these are what reach a
        # second screen: focus it, or drag the current workspace over to it.
        # "+1" cycles, so both are a no-op on a single monitor.
        (bind "${mod} + CTRL + Tab" ''hl.dsp.focus({ monitor = "+1" })'')
        (bind "${mod} + SHIFT + Tab" ''hl.dsp.workspace.move({ monitor = "+1" })'')

        (bind "${mod} + W" (exec "${makoctl} dismiss"))

        (bind "${mod} + space" (exec "wofi --show drun"))
        (bind "${mod} + SHIFT + Q" (exec "shutdown-menu"))
        (bind "${mod} + P" (exec "paper-menu"))
        (bind "${mod} + O" (exec "${wofi-emoji} -t"))
        (bind "${mod} + SHIFT + P" (exec rofi-rbw))

        (bind "${mod} + CTRL + L" (exec hyprlock))

        (bindLocked "XF86AudioMute" (exec "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"))
        (bindLocked "XF86AudioMicMute" (exec "${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))

        (bindLocked "XF86AudioNext" (exec "${playerctl} next"))
        (bindLocked "XF86AudioPrev" (exec "${playerctl} previous"))
        (bindLocked "XF86AudioPlay" (exec "${playerctl} play-pause"))
        (bindLocked "XF86AudioStop" (exec "${playerctl} stop"))

        # Mirrors sway's bindswitch: fold the lid, drop the internal panel.
        # `hyprctl keyword` is legacy-parser only, so the rule is edited from
        # Lua instead; hl.monitor merges into the existing rule, which is what
        # makes `disabled = false` restore the mode and position again.
        (bindLocked "switch:on:Lid Switch" ''function() hl.monitor({ output = "eDP-1", disabled = true }) end'')
        (bindLocked "switch:off:Lid Switch" ''function() hl.monitor({ output = "eDP-1", disabled = false }) end'')

        (bindLockedRepeat "XF86AudioRaiseVolume" (exec "${wpctl} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"))
        (bindLockedRepeat "XF86AudioLowerVolume" (exec "${wpctl} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"))

        (bindLockedRepeat "XF86MonBrightnessUp" (exec "${brightnessctl} set +3%"))
        (bindLockedRepeat "XF86MonBrightnessDown" (exec "${brightnessctl} set 3%-"))
      ];
    };

    # Home Manager emits its own `hyprland.start` hook -- the one that pushes
    # the Wayland environment into systemd and brings up
    # hyprland-session.target -- after everything in `settings`. extraConfig is
    # rendered last, so registering here keeps these running after that, the
    # way `exec-once` ordering did under hyprlang.
    extraConfig = ''
      hl.on("hyprland.start", function()
        hl.exec_cmd("systemctl --user restart waybar")
        hl.exec_cmd("${pkgs.swaybg}/bin/swaybg -i ${config.wallpaper} --mode fill")
      end)
    '';
  };
}
