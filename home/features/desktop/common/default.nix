{ pkgs, ... }:
{
  imports = [
    ./alacritty.nix
    ./banking.nix
    ./firefox.nix
    ./gtk.nix
    ./gimp.nix
    ./imv.nix
    ./ktouch.nix
    ./libreoffice.nix
    ./mpv.nix
    ./playerctl.nix
    ./qt.nix
    ./zathura.nix
  ];

  home.packages = with pkgs; [
    flatpak
  ];
}
