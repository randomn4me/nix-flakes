{ inputs, outputs, ... }:
{
  imports = [
    ./locale.nix
    ./nix.nix
    ./pkgs.nix
  ]
  ++ (builtins.attrValues outputs.nixosModules);

  nixpkgs.config = {
    allowAliases = false;
    allowUnfree = true;
  };

  # Pull borgmatic from stable nixpkgs. On unstable it builds against
  # Python 3.14, whose transitive dep paho-mqtt (borgmatic -> apprise ->
  # paho-mqtt) has a test suite that hangs and gets killed in the Nix
  # sandbox, failing the build. Stable's borgmatic sidesteps the whole
  # chain. The module has no `package` option, so override pkgs.borgmatic
  # directly — this covers both the service and its config validation.
  nixpkgs.overlays = [
    (final: prev: {
      borgmatic =
        (import inputs.nixpkgs-stable {
          inherit (prev.stdenv.hostPlatform) system;
          config.allowUnfree = true;
        }).borgmatic;
    })
  ];

  console.keyMap = "us";

  # NixOS defaults environment.variables.EDITOR to "nano" (programs/environment.nix).
  # Home Manager's nixvim defaultEditor only writes hm-session-vars.sh, which is
  # sourced from ~/.profile and therefore misses the graphical session and any
  # shell started from it, so the system value wins. Set it system-wide instead.
  environment.variables.EDITOR = "nvim";
}
