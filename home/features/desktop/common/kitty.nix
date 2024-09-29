{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.colorscheme) colors;
in
{
  home.sessionVariables.TERMINAL = "kitty";
  programs.kitty = {
    enable = true;
    font = {
      name = "monospace";
      size = 10;
    };
    themeFile = "tokyo_night_night";
  };
}
