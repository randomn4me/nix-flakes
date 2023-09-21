{ pkgs, ... }:

{
  imports = [
    ./locale.nix
    ./nix.nix
    ./pkgs.nix
  ];

  fonts.packages = with pkgs; [
    inconsolata-nerdfont
    vistafonts
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  console = {
    keyMap = "de";
  };
}
