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
    inputs.sops-nix.url = "github:Mic92/sops-nix";
    waybar.url = "github:Alexays/Waybar";

    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprwm-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    astronvim = {
      url = "github:AstroNvim/AstroNvim/v3.42.0";
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

      wallpapers = import ./home/wallpapers;

      nixosConfigurations = {

        peasec = lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/peasec ];
        };

        hetzner = lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/hetzner ];
        };
      };

      homeConfigurations = {
        "phil@peasec" = lib.homeManagerConfiguration {
          pkgs = nixpkgs.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./home/peasec.nix ];
        };

        "r4ndom@hetzner" = lib.homeManagerConfiguration {
          pkgs = nixpkgs.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./home/hetzner.nix ];
        };
      };
    };
}
