{ pkgs, inputs, ... }:
{
  imports = [
    ./global

    ./features/accounts/private
    ./features/accounts/peasec

    ./features/desktop/hyprland
    ./features/multimedia
    ./features/backup
    ./features/rbw

    ./features/productivity

    ./features/cli/udiskie.nix
  ];

  home.packages = with pkgs; [
    texlive.combined.scheme-full
    libreoffice
    zotero
    obsidian
    signal-desktop
    gnumake
    watchexec
    openconnect

    pandoc
    ffmpeg
  ];

  colorscheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;
}
