{
  imports = [
    ./locale.nix
    ./nix.nix
    ./pkgs.nix
  ];

  nixpkgs.config.allowUnfree = true;
  console.keyMap = "de";
  boot.plymouth = {
    enable = true;
  };
}
