{ config, pkgs, ... }:

let inherit (config.colorscheme) colors;
in {
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      effect-blur = "4x3";
      fade-in = 0.1;

      image = config.wallpaper;

      font = "Share Tech Mono";
      font-size = 15;

      line-uses-inside = true;
      disable-caps-lock-text = false;
      show-keyboard-layout = true;
      indicator-caps-lock = true;
      indicator-radius = 40;
      indicator-idle-visible = true;
      #indicator-y-position = 1200; # TODO make position dependent on monitor config

      #color = "#${colors.base00}";
      #inside-color = "#${colors.base00}";

      #layout-bg-color = "${colors.base00}";
      layout-text-color = "${colors.base05}";
      #layout-border-color = "${colors.base00}";

      ring-color = "#${colors.base09}";
      key-hl-color = "#${colors.base0C}";

      ring-ver-color = "#${colors.base0C}";
      text-ver-color = "#${colors.base00}";
      inside-ver-color = "#${colors.base0C}";

      text-clear-color = "#${colors.base01}";
      inside-clear-color = "#${colors.base00}";
      ring-clear-color = "#${colors.base0C}";

      inside-wrong-color = "#${colors.base08}";
      ring-wrong-color = "#${colors.base08}";
      text-wrong-color = "#${colors.base00}";

      text-color = "#${colors.base05}";
    };
  };
}
