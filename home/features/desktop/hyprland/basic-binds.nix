{ lib, ... }:
let
  workspaces = (map toString (lib.range 1 9));
  # Map keys to hyprland directions
  directions = rec {
    left = "l";
    right = "r";
    up = "u";
    down = "d";
    h = left;
    l = right;
    k = up;
    j = down;
  };
in {
  wayland.windowManager.hyprland.settings = {
    bindm = [ "ALT,mouse:272,movewindow" "ALT,mouse:273,resizewindow" ];

    bind = [
      "ALT,q,killactive"

      "ALT,TAB,workspace,previous"
      "ALTSHIFT,space,togglefloating"
    ] ++
      # Change workspace
      (map (n: "ALT,${n},workspace,${n}") workspaces) ++
      # Move window to workspace
      (map (n: "ALTSHIFT,${n},movetoworkspacesilent,${n}") workspaces) ++
      # Move focus
      (lib.mapAttrsToList (key: direction: "ALT,${key},movefocus,${direction}")
        directions) ++
      # Move window in direction
      (lib.mapAttrsToList
        (key: direction: "ALT SHIFT,${key},movewindow,${direction}")
        directions);
  };
}
