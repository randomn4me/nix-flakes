{ inputs, outputs, ... }:

{
  imports = [
    ./locale.nix
    ./nix.nix
  ];

  console = {
    keyMap = "de";
  };
}
