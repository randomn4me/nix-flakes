{
  description = "A r4ndom flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
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

    audacis-blog.url = "git+ssh://forgejo@git.audacis.net/philippkuehn/blog";
    audacis-blog.inputs.nixpkgs.follows = "nixpkgs";

    serify-page.url = "git+ssh://forgejo@git.audacis.net/serify/serify-page";
    serify-page.inputs.nixpkgs.follows = "nixpkgs";

    code-of-courage.url = "git+ssh://gitlab.dev.peasec.de/praktikum/25ss_LG1_CodeOfCourage.git";
    code-of-courage.inputs.nixpkgs.follows = "nixpkgs";

    forge-agent.url = "git+ssh://forgejo@git.audacis.net/philippkuehn/forge-agent";
    forge-agent.inputs.nixpkgs.follows = "nixpkgs";
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
      machines = {
        peasec = {
          system = "x86_64-linux";
          users = [ "phil" ];
        };

        netcup = {
          system = "aarch64-linux";
          users = [ "phil" ];
          extraModules = [ ./hosts/netcup/external-services.nix ];
        };

        macbook-pro-pk = {
          system = "aarch64-darwin";
          users = [ "pkuehn" ];
          hostPath = ./hosts/macbook-work;
          homeFile = ./home/macbook-pro-work.nix;
        };
      };

      isDarwin = machine: lib.hasSuffix "-darwin" machine.system;

      hostPathOf = name: machine: machine.hostPath or ./hosts/${name};
      homeFileOf = name: machine: machine.homeFile or ./home/${name}.nix;

      modulesOf = name: machine: [ (hostPathOf name machine) ] ++ (machine.extraModules or [ ]);

      mkSystem =
        builder: name: machine:
        builder {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = modulesOf name machine;
        };

      mkNixos = mkSystem lib.nixosSystem;
      mkDarwin = mkSystem lib.darwinSystem;

      mkHome =
        name: machine:
        lib.homeManagerConfiguration {
          pkgs = pkgsFor.${machine.system};
          extraSpecialArgs = {
            inherit inputs outputs;
            hostname = name;
          };
          modules = [ (homeFileOf name machine) ];
        };

      systems = lib.unique (lib.mapAttrsToList (_: machine: machine.system) machines);

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
      homeModules = import ./modules/home-manager;

      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      formatter = forEachSystem (pkgs: pkgs.nixfmt-tree);
      devShells = forEachSystem (pkgs: import ./shell.nix { inherit pkgs; });

      nixosConfigurations = lib.mapAttrs mkNixos (lib.filterAttrs (_: m: !isDarwin m) machines) // {
        netcup-core = mkNixos "netcup" (removeAttrs machines.netcup [ "extraModules" ]);
      };

      darwinConfigurations = lib.mapAttrs mkDarwin (lib.filterAttrs (_: m: isDarwin m) machines);

      homeConfigurations = lib.concatMapAttrs (
        name: machine:
        lib.listToAttrs (
          map (user: lib.nameValuePair "${user}@${name}" (mkHome name machine)) (machine.users or [ ])
        )
      ) machines;
    };
}
