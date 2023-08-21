{ pkgs, ... }:

{
  imports = [
    ../../modules/desktop/hyprland/home.nix
  ];

  programs = {
    git = {
      enable = true;
      userName = "Philipp Kühn";
      userEmail = "kuehn@peasec.tu-darmstadt.de";
    };
  };
}
