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

      substituters = [
        "https://hyprland.cachix.org"
        "https://devenv.cachix.org"
      ];

      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];

      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    gc = {
      automatic = true;
      dates = lib.mkDefault "weekly";
      options = "--delete-older-than 14d";
    };

    optimise.automatic = true;

    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
  };
}
