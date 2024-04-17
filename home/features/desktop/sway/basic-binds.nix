{ config, lib, ... }:
{
  wayland.windowManager.sway.config.keybindings =
    let
      workspaces = (map toString (lib.range 1 9));
      # Map keys to sway directions
      directions = {
        h = "left";
        l = "right";
        k = "up";
        j = "down";
      };
      keys = builtins.attrNames directions;
      inherit (config.wayland.windowManager.sway.config) modifier;
      remove_mod = str: builtins.replaceStrings [ "${modifier}+" ] [ "" ] str;
    in
    {
      "${modifier}+q" = "kill";
      "${modifier}+Shift+c" = "reload";

      "${modifier}+u" = "splitv";
      "${modifier}+i" = "splith";

      "${modifier}+Shift+space" = "floating toggle";

      "${modifier}+r" = "mode resize";
    }
    // lib.genAttrs (map (n: "${modifier}+${n}") workspaces) (n: "workspace number ${remove_mod n}")
    // lib.genAttrs (map (n: "${modifier}+Shift+${n}") workspaces) (
      n: "move container to workspace number ${builtins.replaceStrings [ "${modifier}+Shift+" ] [ "" ] n}"
    )
    // lib.genAttrs (map (k: "${modifier}+${k}") keys) (k: "focus ${directions.${remove_mod k}}")
    // lib.genAttrs (map (k: "${modifier}+Shift+${k}") keys) (
      k: "move ${directions.${builtins.replaceStrings [ "${modifier}+Shift+" ] [ "" ] k}}"
    );
}
