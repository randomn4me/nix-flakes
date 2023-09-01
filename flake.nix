{
  description = "A r4ndom flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      user = "phil";
      location = "$HOME/etc";
    in
    {
      nixosConfigurations = (
	import ./hosts {
	  inherit (nixpkgs) lib;
	  inherit inputs nixpkgs nixpkgs-unstable user location home-manager;
	}
      );
    };
}
