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
