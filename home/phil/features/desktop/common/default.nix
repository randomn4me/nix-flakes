{ pkgs, ... }: {
  imports = [
    ./alacritty.nix
    ./banking.nix
    ./firefox.nix
    ./font.nix
    #./gtk.nix
    ./imv.nix
    ./ktouch.nix
    ./mpv.nix
    ./playerctl.nix
    ./qt.nix
    ./zathura.nix
  ];

  home.packages = with pkgs; [ flatpak libreoffice ];
}
