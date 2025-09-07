{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  nix = {
    package = pkgs.lix;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;

      substituters = [ "https://devenv.cachix.org" ];

      trusted-public-keys = [ "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" ];

      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 3d";
      dates = lib.mkDefault "daily";
    };

    optimise.automatic = true;

    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
  };
}
