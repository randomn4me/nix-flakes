{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    fira
    fira-mono
    roboto
    roboto-mono
    roboto-serif
    libertine
    inconsolata
    inconsolata-nerdfont
    vistafonts

    google-fonts

    (pkgs.nerdfonts.override { fonts = [ "ShareTechMono" ]; })
  ];


}
