{ pkgs, ... }: {
  imports = [
    ./alacritty.nix
    ./banking.nix
    ./firefox.nix
    ./font.nix
    ./gtk.nix
    ./imv.nix
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
