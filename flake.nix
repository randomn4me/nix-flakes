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

    hyprpicker.url = "github:hyprwm/hyprpicker";
    waybar.url = "github:Alexays/Waybar";

    astronvim = {
      url = "github:AstroNvim/AstroNvim/v3.41.0";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      systems = [ "aarch64-linux" "x86_64-linux" ];

      forEachSystem = f: lib.genAttrs systems (sys: f pkgsFor.${sys});
      pkgsFor = lib.genAttrs systems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });

    in {
      inherit lib;
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      formatter = forEachSystem (pkgs: pkgs.nixpkgs-fmt);

      wallpapers = import ./home/phil/wallpapers;

      nixosConfigurations = {

        work = lib.nixosSystem {
          modules = [ ./hosts/work ];
          specialArgs = { inherit inputs outputs; };
        };

        hetzner = lib.nixosSystem {
          modules = [ ./hosts/hetzner ];
          specialArgs = { inherit inputs outputs; };
        };
      };

      homeConfigurations = {
        "phil@work" = lib.homeManagerConfiguration {
          modules = [ ./home/phil/work.nix ];
          pkgs = nixpkgs.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
        };

        #"phil@work" = lib.homeManagerConfiguration {
        #  modules = [ ./home/phil/work.nix ];
        #  pkgs = nixpkgs.x86_64-linux;
        #  extraSpecialArgs = {inherit inputs outputs;};
        #};
      };
    };
}
