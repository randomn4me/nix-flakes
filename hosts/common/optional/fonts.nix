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

      (pkgs.nerdfonts.override { fonts = [ "FiraCode" "ShareTechMono" ]; })
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Fira Sans" ];
        sansSerif = [ "Fira Sans" ];
        monospace = [
          "FiraCode Nerd Font Mono"
          "Noto Color Emoji"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
