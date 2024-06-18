{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      corefonts
      fira
      roboto
      roboto-serif
      inconsolata-nerdfont
      vistafonts
      noto-fonts-color-emoji

      (pkgs.google-fonts.override { fonts = [ "ShareTechMono" ]; })

      (pkgs.nerdfonts.override { fonts = [ "ShareTechMono" ]; })
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Fira Sans" ];
        sansSerif = [ "Fira Sans" ];
        monospace = [
          "Inconsolata Nerd Font Mono"
          "Noto Color Emoji"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
