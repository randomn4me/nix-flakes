{ pkgs, ... }:
{
  imports = [
    # ./alacritty.nix
    ./chrome.nix
    ./firefox.nix
    ./gtk.nix
    ./imv.nix
    ./libreoffice.nix
    ./ghostty.nix
    ./mpv.nix
    ./playerctl.nix
    ./qt.nix
    ./zathura.nix
  ];

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 12;
  };
}
