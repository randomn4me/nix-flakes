{ outputs, ... }:
{
  imports = [
    ./locale.nix
    ./nix.nix
    ./pkgs.nix
  ] ++ (builtins.attrValues outputs.nixosModules);

  nixpkgs.config = {
    allowAliases = false;
    allowUnfree = true;
  };

  console.keyMap = "de";
}
