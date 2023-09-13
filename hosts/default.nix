{ lib, inputs, nixpkgs, nixpkgs-unstable, home-manager, ... }:

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
      inherit inputs unstable system user location;
    };

    modules = [
      ./work
      ./configuration.nix

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit unstable user;
        };
        #home-manager.users.${user} = import ./home.nix;
        home-manager.users.${user} = import ./home.nix;
      }

    ];
  };
}
