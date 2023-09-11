{ pkgs, config, ... }:

{
  services.taskwarrior-sync = {
    enable = true;
    frequency = "1m";
  };
}
