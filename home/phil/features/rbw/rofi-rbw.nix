{ pkgs, ... }: {
  home.packages = with pkgs; [ rofi-rbw ];

  xdg.configFile."rofi-rbw.rc".text = ''
    action = copy
    clear-after = 15
  '';
}
