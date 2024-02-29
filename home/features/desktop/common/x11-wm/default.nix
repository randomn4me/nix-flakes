{ pkgs, ... }: {
  imports = [
    #./autorandr.nix
    #./rofi.nix
    ./screenlocker.nix
    ./dunst.nix
    ./dmenu.nix
    ./autorandr.nix
  ];

  home.packages = with pkgs; [
    xsel
    scrot
    xorg.xbacklight
    xorg.xrandr
    arandr
    i3lock-color
  ];
}
