{
  description = "A r4ndom flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors.url = "github:misterio77/nix-colors";

    # Hyprland
    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprwm-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    waybar.url = "github:Alexays/Waybar";

    astronvim = {
      url = "github:AstroNvim/AstroNvim/v3.40.3";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      systems = [
        #"aarch64-linux"
        #"i686-linux"
        "x86_64-linux"
        #"aarch64-darwin"
        #"x86_64-darwin"
      ];
      forEachSystem = f: lib.genAttrs systems (sys: f pkgsFor.${sys});
      pkgsFor = nixpkgs.legacyPackages;
    in {
      inherit lib;
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });

      wallpapers = import ./home/phil/wallpapers;

      nixosConfigurations = {

        work = lib.nixosSystem {
          modules = [ ./hosts/work ];
          specialArgs = { inherit inputs outputs; };
        };

        # work = lib.nixosSystem {
        #   modules = [ ./hosts/work ];
        #   specialArgs = { inherit inputs outputs; };
        # };
      };

      homeConfigurations = {
        "phil@work" = lib.homeManagerConfiguration {
          modules = [ ./home/phil/work.nix ];
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };

        #"phil@work" = lib.homeManagerConfiguration {
        #  modules = [ ./home/phil/work.nix ];
        #  pkgs = nixpkgs.legacyPackages.x86_64-linux;
        #  extraSpecialArgs = {inherit inputs outputs;};
        #};
      };
    };
}
