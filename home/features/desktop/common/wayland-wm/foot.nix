{ lib, ... }:
{
  home.sessionVariables.TERMINAL = lib.mkForce "foot";

  programs.foot = {
    enable = true;

    settings = {
      main.term = "xterm-direct";
      mouse.hide-when-typing = true;
    };
  };
}
