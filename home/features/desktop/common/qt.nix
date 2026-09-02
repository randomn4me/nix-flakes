{ pkgs, config, ... }:
{
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style = {
      name = "gtk2";
      package = pkgs.qt6Packages.qt6gtk2;
    };
  };
}
