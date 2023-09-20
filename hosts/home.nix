{ config, lib, pkgs, user, ... }:

let
  homeDir = config.home.homeDirectory;
in
{
  imports = 
    (import ../modules/programs) ++
    (import ../modules/editors) ++
    (import ../modules/services) ++ [
      ../modules/desktop/hyprland/home.nix
      ../modules/editors/nvim/home.nix
      ../modules/scripts/home.nix
      ../modules/programs/zoxide.nix
      ../modules/shell/bash.nix
    ];


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
      signal-desktop

      libreoffice
      xfce.thunar

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
    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${homeDir}/tmp";
      download = "${homeDir}/tmp";
      documents = "${homeDir}/usr/docs";
      music = "${homeDir}/usr/music";
      pictures = "${homeDir}/usr/pics";
      videos = "${homeDir}/usr/vids";
      publicShare = null;
      templates = null;
    };
  };

}
