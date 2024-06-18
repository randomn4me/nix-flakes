{ pkgs, ... }:
{
  home.packages = with pkgs; [
    signal-desktop
    scli
  ];

  xdg.configFile."sclirc".text = ''
    enable-notifications = true
    wrap-at = 80
  '';
}
