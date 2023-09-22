{ lib, ... }:
let
  workspaces = (map toString (lib.range 0 9));
  # Map keys to hyprland directions
  directions = rec {
    left = "l" ; right = "r" ; up = "u" ; down = "d" ;
    h = left   ; l = right   ; k = up   ; j = down   ;
  };
in {
  wayland.windowManager.hyprland.settings = {
    bindm = [
      "ALT,mouse:272,movewindow"
      "ALT,mouse:273,resizewindow"
    ];

    bind = [
      "ALT,q,killactive"

      "ALTSHIFT,e,exit"

      "ALT,TAB,workspace,previous"
      "ALT,mouse_down,workspace,e+1"
      "ALT,mouse_up,workspace,e-1"

      #"ALT,s,togglesplit"
      #"ALT,f,fullscreen,1"
      #"ALTSHIFT,f,fullscreen,0"
      "ALTSHIFT,space,togglefloating"

      #"ALT,minus,splitratio,-0.25"
      #"ALTSHIFT,minus,splitratio,-0.3333333"

      #"ALT,equal,splitratio,0.25"
      #"ALTSHIFT,equal,splitratio,0.3333333"

      #"ALT,g,togglegroup"
      #"ALT,apostrophe,changegroupactive,f"
      #"ALTSHIFT,apostrophe,changegroupactive,b"

      #"ALT,u,togglespecialworkspace"
      #"ALTSHIFT,u,movetoworkspace,special"
    ] ++
    # Change workspace
    (map (n:
      "ALT,${n},workspace,name:${n}"
    ) workspaces) ++
    # Move window to workspace
    (map (n:
      "ALTSHIFT,${n},movetoworkspacesilent,name:${n}"
    ) workspaces) ++
    # Move focus
    (lib.mapAttrsToList (key: direction:
      "ALT,${key},movefocus,${direction}"
    ) directions);
  };
}
