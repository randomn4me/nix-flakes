{
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
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };

    optimise.automatic = true;
  };
}
