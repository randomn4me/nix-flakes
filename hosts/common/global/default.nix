{
  imports = [
    ./locale.nix
    ./nix.nix
    ./pkgs.nix
  ];

  nixpkgs.config = {
    allowAliases = false;
    allowUnfree = true;
  };

  console.keyMap = "de";
}
