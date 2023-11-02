{ pkgs, ... }: {
  imports = [
    #./autorandr.nix
    ./rofi.nix
    ./dmenu.nix
    ./lemonbar.nix
  ];

  home.packages = with pkgs; [
    xclip
    xsel
    scrot
    xorg.xbacklight
    xorg.xrandr
    arandr
    i3lock-color
  ];

}
