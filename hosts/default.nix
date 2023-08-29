{ lib, inputs, nixpkgs, nixpkgs-unstable, home-manager, hyprland, user, location, ... }:

let
  system = "x86_64-linux";

  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  unstable = import nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };

  lib = nixpkgs.lib;
in
{
  work = lib.nixosSystem {
    inherit system;
    specialArgs = {
      inherit inputs unstable system user location hyprland;
    };

    modules = [
      ./work
      ./configuration.nix

      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit unstable user;
        };
        home-manager.users.${user} = {
          imports = [
            ./home.nix
            ./work/home.nix
          ];
        };
      }

    ];
  };
}
