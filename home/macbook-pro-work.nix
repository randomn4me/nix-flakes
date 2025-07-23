{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./features/ssh/peasec.nix
    ./features/ssh/private.nix
  ];

  home.homeDirectory = "/Users/pkuehn";

  programs.home-manager.enable = true;
  home.stateVersion = "25.05";
}
