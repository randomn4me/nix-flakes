{ config, lib, pkgs, unstable, user, ... }:

{
  imports = 
    (import ../modules/programs);
  #  (import ../modules/services);

  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";

    packages = with pkgs; [
      alacritty
      btop

      feh
      mpv
      firefox-wayland
      rbw
      pinentry-qt
      obsidian

      libreoffice

      unzip
      zip

    ];

    stateVersion = "23.05";
  };

  programs = {
    home-manager.enable = true;
  };

  gtk = {
    enable = true;
    theme.name = "Darcula";
  };

  #xdg = {
  #  enable = true;
  #};

}
