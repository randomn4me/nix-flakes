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

      # Pin the global registry to empty so `nixpkgs#...` only resolves through
      # our locked local registry below, never an unpinned online fetch.
      flake-registry = "";

      use-xdg-base-directories = true;

      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
      dates = lib.mkDefault "daily";
    };

    optimise.automatic = true;

    # Fully on flakes: drop the legacy channel system and make <nixpkgs> resolve
    # to the same locked input as everything else.
    channel.enable = false;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    # Registering an input here forces it, so the private git+ssh inputs are
    # excluded: they are only ever consumed by netcup's service modules, and
    # registering them globally makes an unreachable remote (expired key, VPN
    # off, rotated host key) break rebuilds on every host.
    registry = lib.mapAttrs (_: value: { flake = value; }) (
      lib.removeAttrs inputs [
        "audacis-blog"
        "serify-page"
        "code-of-courage"
        "forge-agent"
      ]
    );
  };
}
