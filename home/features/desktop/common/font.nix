{ pkgs, ... }:
{
  fontProfiles = {
    enable = true;
    monospace = {
      family = "Inconsolata Regular";
      package = pkgs.nerd-fonts.inconsolata;
    };
    regular = {
      family = "Inconsolata Regular";
      package = pkgs.inconsolata;
    };
  };
}
