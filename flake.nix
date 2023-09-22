{
  description = "A r4ndom flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    inherit (self) outputs;
    forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
      ];
  in rec {
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    #packages = forAllSystems (pkgs: import ./pkgs { inherit pkgs; });

    nixosConfigurations = {
      work = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };
        modules = [ ./hosts/work ];
      };

      # work = nixpkgs.lib.nixosSystem {
      #   specialArgs = { inherit inputs outputs; };
      #   modules = [ ./hosts/work ];
      # };
    };
  };
}
