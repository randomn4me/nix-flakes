{
  config,
  pkgs,
  lib,
  ...
}:

let
  alacritty-xterm = pkgs.writeShellScriptBin "xterm" ''
    ${config.programs.alacritty.package}/bin/alacritty "$@"
  '';
in
{
  home = {
    packages = [ alacritty-xterm ];
    sessionVariables.TERMINAL = lib.mkDefault "alacritty";
  };

  programs.alacritty = {
    enable = true;
    settings.env.TERM = "xterm-direct";
  };
}
