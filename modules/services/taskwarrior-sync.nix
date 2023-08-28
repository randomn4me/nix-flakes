{ pkgs, config, ... }:

{
  services.taskwarrior-sync = {
    enable = true;
  };
}
