{ inputs, lib, pkgs, config, outputs, ... }:
{
  imports = [
    imputs.nix-colors.homeManagerModule
    ../editors/nvim
    ../shell/bash.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      warn-dirty = false;
    };
  };

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  home = {
    username = lib.mkDefault "r4ndom";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.05";
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = {
      FLAKE = "$HOME/etc";
    };
  };

  colorscheme = lib.mkDefault colorSchemes.rose-pine;
  home.file.".colorscheme".text = config.colorscheme.rose-pine;
}
