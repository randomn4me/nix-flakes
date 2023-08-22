{ pkgs, ... }:

{
  imports = [
    ../../modules/desktop/hyprland/home.nix
    ../../modules/editors/nvim/home.nix
    ../../modules/scripts/home.nix
  ];

  programs = {
    git = {
      userName = "Philipp Kühn";
      userEmail = "kuehn@peasec.tu-darmstadt.de";
    };
  };
}
