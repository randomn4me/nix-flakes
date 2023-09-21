{ pkgs, inputs, ... }:
{
  imports = [
    ./global
    #./features/desktop/wireless
    ./features/desktop/hyprland
    #./features/pass
  ];

  home.packages = with pkgs; [
    texlive.combined.scheme-full
  ];

  #monitors = [
  #  {
  #    name = "eDP-1";
  #    width = 1920;
  #    height = 1080;
  #    primary = true;
  #  }
  #];

  colorscheme = inputs.nix-colors.colorSchemes.rose-pine;
}
