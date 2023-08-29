{
  description = "A r4ndom flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, hyprland, ... }:
    let
      user = "phil";
      location = "$HOME/etc";
    in
    {
      nixosConfigurations = (
	import ./hosts {
	  inherit (nixpkgs) lib;
	  inherit inputs nixpkgs nixpkgs-unstable user location home-manager hyprland;
	}
      );
    };
}
