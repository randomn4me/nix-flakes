{ pkgs, ... }:
{
  fontProfiles = {
    enable = true;
    monospace = {
      family = "Inconsolata Regular";
      package = pkgs.inconsolata-nerdfont;
    };
    regular = {
      family = "Inconsolata Regular";
      package = pkgs.inconsolata;
    };
  };
}
