{ config, pkgs, ... }:

let
  inherit (config.colorscheme) colors;
in
{
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      effect-blur = "4x3";
      fade-in = 1;

      image = config.wallpaper;

      font = "Share Tech Mono";
      font-size = 14;

      line-uses-inside = true;
      show-failed-attempts = true;
      ignore-empty-password = true;
      disable-caps-lock-text = false;
      show-keyboard-layout = true;
      indicator-caps-lock = true;
      indicator-radius = 40;
      indicator-idle-visible = false;

      layout-text-color = "#${colors.base05}";

      ring-color = "#${colors.base05}";
      key-hl-color = "#FFFFFF";

      ring-ver-color = "#${colors.base04}";
      text-ver-color = "#000000";
      inside-ver-color = "#${colors.base04}";

      inside-clear-color = "#000000";
      ring-clear-color = "#B1252E";

      inside-wrong-color = "#${colors.base05}";
      ring-wrong-color = "#B1252E";
      text-wrong-color = "#000000";

      text-color = "#${colors.base05}";
    };
  };
}
