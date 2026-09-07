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

    serify-page.url = "git+ssh://forgejo@git.audacis.net/serify/serify-page?ref=feat/one-pager";
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

      # ── machines ────────────────────────────────────────────────────────
      #
      # The one place a machine is declared. To add another:
      #
      #   1. hosts/<name>/{default,hardware-configuration}.nix
      #   2. home/<name>.nix -- hosts/common/users/<user> imports the home
      #      config by hostname, so the file name has to match `<name>`
      #   3. one entry here
      #   4. a creation_rule in .sops.yaml, if the host holds secrets
      #
      # `system` is declared once and drives both the machine and its
      # home-manager output, so the two cannot drift apart -- the macbook
      # spent a while being built as aarch64-linux because they were written
      # out separately.
      #
      # Optional per-machine keys:
      #   hostPath     path to the host module      (default ./hosts/<name>)
      #   homeFile     path to the home config      (default ./home/<name>.nix)
      #   users        standalone home-manager outputs to generate, as
      #                homeConfigurations."<user>@<name>"
      #   extraModules extra NixOS/darwin modules
      machines = {
        peasec = {
          system = "x86_64-linux";
          users = [ "phil" ];
        };

        netcup = {
          system = "aarch64-linux";
          users = [ "phil" ];
          # Evaluating this needs every private git remote reachable;
          # nixosConfigurations.netcup-core below is the same box without it.
          extraModules = [ ./hosts/netcup/external-services.nix ];
        };

        # Host dir, flake output and home file were each named differently
        # before this table existed; the mapping is spelled out rather than
        # renamed, since the output name is what darwin-rebuild is invoked with.
        macbook-pro-pk = {
          system = "aarch64-darwin";
          users = [ "pkuehn" ];
          hostPath = ./hosts/macbook-work;
          homeFile = ./home/macbook-pro-work.nix;
        };
      };

      # ── plumbing ────────────────────────────────────────────────────────
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

      # homeManagerConfiguration takes pkgs directly, which makes the config's
      # own nixpkgs.config a no-op -- allowUnfree therefore has to be set in
      # pkgsFor below as well as in home/global. The NixOS-integrated
      # home-manager builds its own pkgs and does read home/global's setting.
      mkHome =
        name: machine:
        lib.homeManagerConfiguration {
          pkgs = pkgsFor.${machine.system};
          # `hostname` stands in for osConfig.networking.hostName, which a
          # standalone home config has no access to.
          extraSpecialArgs = {
            inherit inputs outputs;
            hostname = name;
          };
          modules = [ (homeFileOf name machine) ];
        };

      # Only the systems some machine actually runs on.
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
      # nixfmt-tree is nixfmt wrapped in treefmt: `nix fmt` with no arguments
      # formats the whole tree, honouring .gitignore.
      formatter = forEachSystem (pkgs: pkgs.nixfmt-tree);
      devShells = forEachSystem (pkgs: import ./shell.nix { inherit pkgs; });

      nixosConfigurations = lib.mapAttrs mkNixos (lib.filterAttrs (_: m: !isDarwin m) machines) // {
        # peasec/netcup without their private-input services. Everything that
        # holds data -- nginx, acme, postgres, forgejo, vaultwarden, zulip,
        # ntfy, the backups -- is still in here, so the box stays rebuildable
        # when one of those remotes is down.
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
