{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      fira
      roboto
      roboto-serif
      inconsolata-nerdfont
      vistafonts
  
      (pkgs.google-fonts.override { fonts = [ "ShareTechMono" ]; })
  
      (pkgs.nerdfonts.override { fonts = [ "ShareTechMono" ]; })
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Fira Sans" ];
        sansSerif = [ "Fira Sans" ];
        monospace = [ "Inconsolata Nerd Font Mono" "Noto Color Emoji" ];
      };
    };
  };
}
