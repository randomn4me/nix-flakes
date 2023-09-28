{ pkgs, inputs, ... }:
{
  imports = [
    ./global
    #./features/desktop/wireless
    ./features/desktop/hyprland
    ./features/multimedia
    ./features/backup
    #./features/rbw

    ./features/productivity

    ./features/cli/udiskie.nix
    #./features/pass
  ];

  home.packages = with pkgs; [
    texlive.combined.scheme-full
    libreoffice
    zotero
    obsidian
    signal-desktop
    thunderbird
    gnumake
  ];

  #monitors = [
  #  {
  #    name = "eDP-1";
  #    width = 1920;
  #    height = 1080;
  #    primary = true;
  #  }
  #];

  colorscheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;
}
