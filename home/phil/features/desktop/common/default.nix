{ pkgs, ... }: {
  imports = [
    ./alacritty.nix
    ./banking.nix
    ./imv.nix
    ./firefox.nix
    ./gtk.nix
    ./mpv.nix
    ./playerctl.nix
    ./qt.nix
    ./zathura.nix
  ];

  home.packages = with pkgs; [
    gtk3 # For gtk-launch
    flatpak
    libreoffice
  ];
}
