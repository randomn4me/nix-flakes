{ config, ... }:
let inherit (config.colorscheme) colors;
in {
  services.mako = {
    enable = true;
    anchor = "top-center";
    defaultTimeout = 8000;
    layer = "overlay";

    width = 400;
    height = 150;

    borderSize = 2;
    borderRadius = 5;

    textColor = "#${colors.base05}";
    backgroundColor = "#${colors.base02}";
    borderColor = "#${colors.base0D}";
  };
}
