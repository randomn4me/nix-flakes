{ pkgs, config, ... }:
{
  home.packages = with pkgs; [ rofi-rbw ];

  xdg.configFile."rofi-rbw.rc".text = ''
    action = copy
    clear-after = 15
    selector = ${if config.programs.wofi.enable then "wofi" else "bemenu"}
  '';
}
