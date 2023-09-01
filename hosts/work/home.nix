{ pkgs, ... }:

{
  imports = [
    ../../modules/desktop/hyprland/home.nix
    ../../modules/editors/nvim/home.nix
    ../../modules/scripts/home.nix
    ../../modules/programs/zoxide.nix
    ../../modules/shell/bash.nix
  ];

  programs = {
    git = {
      userName = "Philipp Kühn";
      userEmail = "kuehn@peasec.tu-darmstadt.de";
    };
  };
}
