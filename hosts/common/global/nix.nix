{ inputs, lib, ... }:
{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 3d";
    };

    # TODO understand
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
  };
}
