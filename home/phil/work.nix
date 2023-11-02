{ pkgs, inputs, config, ... }:
{
  imports = [
    ./global

    ./features/accounts/private
    ./features/accounts/peasec

    ./features/desktop/hyprland
    #./features/desktop/cwm
    ./features/multimedia
    ./features/backup
    ./features/rbw

    ./features/productivity

    ./features/cli/udiskie.nix
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "zotero-6.0.27"
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
