{ pkgs, config, ... }:
{
  home.packages = [ pkgs.sptlrx ];
  xdg.configFile."sptlrx/config.yaml".text = ''
    player: mopidy
    mopidy:
      address: 127.0.0.1:6680
  '';
}
