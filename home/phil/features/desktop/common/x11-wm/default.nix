{ pkgs, ... }:
{
  imports = [
    #./autorandr.nix
    ./lemonbar.nix
    ./rofi.nix
  ];

  home.packages = with pkgs; [
    xclip
    xsel
    scrot
    xorg.xbacklight
    xorg.xrandr
    arandr
  ];

}
