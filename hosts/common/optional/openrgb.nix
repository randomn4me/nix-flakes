{ pkgs, ... }:
{
  home.packages = with pkgs; [ openrgb-with-all-plugins ];
  services.hardware.openrgb.enable = true;
}
