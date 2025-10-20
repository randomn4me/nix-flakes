{
  description = "A r4ndom flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-colors.url = "github:misterio77/nix-colors";

    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    audacis-blog.url = "git+https://git.audacis.net/philippkuehn/blog";
    audacis-blog.inputs.nixpkgs.follows = "nixpkgs";

    audax-page.url = "git+ssh://git.audacis.net/philippkuehn/audax-page";
    audax-page.inputs.nixpkgs.follows = "nixpkgs";

    audax-dashboard.url = "git+ssh://forgejo@git.audacis.net/philippkuehn/audax-demo.git";
    audax-dashboard.inputs.nixpkgs.follows = "nixpkgs";

    joshua.url = "git+ssh://git@gitlab.dev.peasec.de/philippkuehn/joshua-mock-dashboard.git";
    joshua.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib // nix-darwin.lib;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
      ];

      forEachSystem = f: lib.genAttrs systems (sys: f pkgsFor.${sys});
      pkgsFor = lib.genAttrs systems (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );
    in
    {
      inherit lib;
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      formatter = forEachSystem (pkgs: pkgs.nixfmt-rfc-style);

      wallpapers = import ./home/wallpapers;

      nixosConfigurations = {
        peasec = lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [ ./hosts/peasec ];
        };

        netcup = lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [ ./hosts/netcup ];
        };
      };

      darwinConfigurations = {
        macbook-pro-pk = nix-darwin.lib.darwinSystem {
          modules = [ ./hosts/macbook-work ];

        };
      };

      homeConfigurations = {
        "phil@peasec" = lib.homeManagerConfiguration {
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = {
            inherit inputs outputs;
          };
          modules = [ ./home/peasec.nix ];
        };

        "phil@netcup" = lib.homeManagerConfiguration {
          pkgs = pkgsFor.aarch64-linux;
          extraSpecialArgs = {
            inherit inputs outputs;
          };
          modules = [ ./home/netcup.nix ];
        };
      };
    };
}
