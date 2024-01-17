{ config, ... }: let
  terminal = config.home.sessionVariables.TERMINAL;
in {
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "workspace 1, ${terminal}"

      "workspace 3, Zotero"
      "workspace 3, libreoffice"
      "workspace 3, obsidian"


      "workspace 4, neomutt"
      "workspace 4, Signal"

      "workspace 5, firefox"

      "workspace 6, mpv"
      "workspace 6, zoom"

      "workspace 8, virtualbox"

      "workspace 9, ncmpcpp"

      "float, zoom"
      "float, Master-Password"
      "float, Extension"
    ];
  };
}
