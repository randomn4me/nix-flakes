{ config, lib, ... }:
let
  workspaces = (map toString (lib.range 1 9));
  # Map keys to hyprland directions
  directions = {
    h = "left";
    l = "right";
    k = "up";
    j = "down";
  };
  keys = builtins.attrNames directions;
in
{
  wayland.windowManager.sway.config.keybindings =
    let
      inherit (config.wayland.windowManager.sway.config) modifier;
    in
    {
      "${modifier}+q" = "kill";
      "${modifier}+Shift+c" = "reload";

      "${modifier}+u" = "splitv";
      "${modifier}+i" = "splith";

      "${modifier}+Shift+space" = "floating toggle";

      "${modifier}+r" = "mode resize";
    }
    //

      # workspaces
      lib.genAttrs (map (n: "${modifier}+${n}" workspaces) (n: "workspace number ${n}"))
    // lib.genAttrs (
      map (n: "${modifier}+Shift+${n}" workspaces) (n: "move container to workspace number ${n}")
    )
    //

      # directions
      lib.genAttrs (map (k: "${modifier}+${k}" keys) (k: "focus ${directions.${k}}"))
    // lib.genAttrs (map (k: "${modifier}+Shift+${k}" keys) (k: "move ${directions.${k}}"));
}
