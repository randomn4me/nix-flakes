{ inputs, outputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager

    ./locale.nix
    ./nix.nix
  ];

  home-manager.extraSpecialArgs = { inherit inputs outputs; };

  console = {
    keyMap = "de";
  };
}
