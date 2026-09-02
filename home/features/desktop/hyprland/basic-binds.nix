{ lib, ... }:
let
  workspaces = lib.range 1 9;

  # hjkl as directions.
  directions = {
    h = "l";
    l = "r";
    k = "u";
    j = "d";
  };

  hl = import ./lib.nix { inherit lib; };
  inherit (hl)
    mod
    exec
    bind
    bindRepeat
    ;
in
{
  wayland.windowManager.hyprland.settings.bind = [
    (bind "${mod} + Q" "hl.dsp.window.close()")
    (bind "${mod} + SHIFT + C" (exec "hyprctl reload"))

    # Hyprland has no "split the focused container"; it sets the direction the
    # *next* window opens in instead.
    (bind "${mod} + U" ''hl.dsp.layout("preselect d")'')
    (bind "${mod} + I" ''hl.dsp.layout("preselect r")'')

    (bind "${mod} + SHIFT + space" ''hl.dsp.window.float({ action = "toggle" })'')

    (bind "${mod} + R" ''hl.dsp.submap("resize")'')
  ]
  ++ map (n: bind "${mod} + ${toString n}" "hl.dsp.focus({ workspace = ${toString n} })") workspaces
  ++ map (
    n: bind "${mod} + SHIFT + ${toString n}" "hl.dsp.window.move({ workspace = ${toString n} })"
  ) workspaces
  ++ lib.mapAttrsToList (
    key: dir: bind "${mod} + ${key}" ''hl.dsp.focus({ direction = "${dir}" })''
  ) directions
  ++ lib.mapAttrsToList (
    key: dir: bind "${mod} + SHIFT + ${key}" ''hl.dsp.window.move({ direction = "${dir}" })''
  ) directions;

  # `$mod+r` enters a resize mode that hjkl drives.
  wayland.windowManager.hyprland.submaps.resize.settings.bind = [
    (bindRepeat "h" "hl.dsp.window.resize({ x = -20, y = 0, relative = true })")
    (bindRepeat "l" "hl.dsp.window.resize({ x = 20, y = 0, relative = true })")
    (bindRepeat "k" "hl.dsp.window.resize({ x = 0, y = -20, relative = true })")
    (bindRepeat "j" "hl.dsp.window.resize({ x = 0, y = 20, relative = true })")

    (bind "escape" ''hl.dsp.submap("reset")'')
    (bind "Return" ''hl.dsp.submap("reset")'')
  ];
}
