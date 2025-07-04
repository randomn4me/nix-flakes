{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      corefonts
      fira
      roboto
      roboto-serif
      noto-fonts-color-emoji
      nerd-fonts.inconsolata
      nerd-fonts.shure-tech-mono
      nerd-fonts.fira-code
      nerd-fonts.fira-mono

      (pkgs.google-fonts.override { fonts = [ "ShareTechMono" ]; })
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
