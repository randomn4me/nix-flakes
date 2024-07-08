{ config, pkgs, ... }:

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
    };
  };
}
