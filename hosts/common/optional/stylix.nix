{
  pkgs,
  outputs,
  lib,
  ...
}:
{
  stylix = {
    enable = true;
    image = outputs.wallpapers.aenami-far-from-tomorrow;
    base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Mdern-Ice";
    };

    fonts = {
      serif = {
        package = pkgs.fira;
        name = "Fira Sans";
      };
      sansSerif = {
        package = pkgs.fira;
        name = "Fira Sans";
      };
      monospace = {
        package = pkgs.inconsolata-nerdfont;
        name = "Inconsolata Nerdfont";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
  };
}
