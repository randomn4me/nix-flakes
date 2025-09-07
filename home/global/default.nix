{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}:
let
  inherit (inputs.nix-colors) colorSchemes;
in
{
  imports = [
    inputs.nix-colors.homeManagerModule
    ../features/cli
  ]
  ++ (builtins.attrValues outputs.homeManagerModules);

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicat = (_: true);
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };
  };

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  home = {
    username = lib.mkDefault "phil";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "25.05";
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables.FLAKE = "${config.home.homeDirectory}/etc";
  };

  home.file."var/misc/r4ndom".text = builtins.readFile ./r4ndom.txt;

  systemd.user.startServices = "sd-switch";

  colorscheme = lib.mkDefault colorSchemes.rose-pine;
  home.file.".colorscheme".text = config.colorscheme.slug;
  home.file.".colorscheme-colors".text = builtins.concatStringsSep "\n" (
    lib.mapAttrsToList (name: colorcode: "${name} = #${colorcode}") config.colorscheme.colors
  );
}
