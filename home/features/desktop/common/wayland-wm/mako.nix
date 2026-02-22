{ config, ... }:
let
  colors = config.colorscheme.palette;
in
{
  services.mako = {
    enable = true;
    settings = {
      anchor = "bottom-right";
      defaultTimeout = 8000;
      layer = "overlay";

      width = 400;
      height = 150;

      borderSize = 2;
      borderRadius = 5;

      font = "monospace 12";
      textColor = "#${colors.base05}";
      backgroundColor = "#010101";
      borderColor = "#B1252E";
    };
  };
}
