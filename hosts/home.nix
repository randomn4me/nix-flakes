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

    bash = {
      enableCompletion = true;

      historySize = 10000;
      historyFile = "\${HOME}/.bash_history";
      historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
      historyIgnore = [ "ls" "cd" "exit" ];

      shellAliases = {
        ll = "ls -lhF --color=auto";
        la = "ls -ahF --color=auto";

        ".." = "cd ..";
        rm = "rm -i";
        mv = "mv -i";
        cp = "cp -r";
        mkdir = "mkdir -p";
        o = "xdg-open";

        cal = "cal -m";
        disks="echo '╓───── m o u n t . p o i n t s'; echo '╙────────────────────────────────────── ─ ─ '; lsblk -a; echo ''; echo '╓───── d i s k . u s a g e'; echo '╙────────────────────────────────────── ─ ─ '; df -h;";
      };

      initExtra = "echo hi";
    };
  };

  gtk = {
    enable = true;
    theme.name = "Darcula";
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
