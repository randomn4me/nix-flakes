{ lib, ... }:
let
  # Rules are keyed by `name`: reusing one on reload updates that rule in place
  # instead of registering a second copy of it.
  toWorkspace = workspace: name: class: {
    inherit name workspace;
    match.class = class;
  };
in
{
  # Hyprland matches Wayland app-ids and XWayland WM_CLASS through the same
  # `class` prop, so one rule per application covers both.
  wayland.windowManager.hyprland.settings.window_rule = [
    (toWorkspace 2 "firefox" "^(firefox)$")
    (toWorkspace 2 "chrome" "^([Gg]oogle-chrome)$")

    (toWorkspace 3 "zotero" "^(Zotero)$")
    (toWorkspace 3 "libreoffice" "^(libreoffice.*)$")
    (toWorkspace 3 "obsidian" "^(obsidian)$")

    (toWorkspace 4 "signal" "^(Signal|signal)$")
    (toWorkspace 4 "element" "^(im\\.riot\\.Riot|Element)$")

    (toWorkspace 6 "mpv" "^(mpv)$")
    (toWorkspace 6 "zoom" "^(zoom)$")

    (toWorkspace 8 "virt-manager" "^(virt-manager)$")
  ];
}
