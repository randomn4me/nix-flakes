{ config, ... }:
{
  programs.rofi = {
    enable = true;

    font = "Share Tech Mono 18";

    location = "center";
    terminal = config.home.sessionVariables.TERMINAL;

    cycle = true;
  };
}
