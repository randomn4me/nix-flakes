{
  imports = [
    ./locale.nix
    ./nix.nix
    ./pkgs.nix
    ./sops.nix
  ];

  nixpkgs.config.allowUnfree = true; 
  console.keyMap = "de"; 
}
