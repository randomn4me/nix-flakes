{
  inputs,
  outputs,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/phil

    ../common/optional/sops.nix
  ];

  # Podman 5.8.7 (CVE fix in buildah/copier) refuses to copy into a container
  # through an absolute symlink, so every Forgejo CI job on Debian/Ubuntu images
  # (/var/run -> /run) fails with "copyContent: ... path escapes from parent".
  # Keep 5.8.6 until a fixed podman lands in nixpkgs:
  # https://github.com/podman-container-tools/podman/issues/29805
  # (.github/workflows/podman-fix-watch.yml opens an issue once it is closed).
  nixpkgs.overlays = [
    (final: prev: {
      inherit (inputs.nixpkgs-podman.legacyPackages.${prev.stdenv.hostPlatform.system}) podman;
    })
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # The ESP (/boot) is only 255 MB and each generation stores a kernel + initrd
  # (~85 MB on aarch64 in practice). Nix GC never prunes /boot — only the
  # bootloader install does, bounded by this limit. Cap it so daily rebuilds
  # can't overflow the ESP and abort the switch: 3 gens overflowed 255 MB, so
  # keep 2 (≈ 170 MB, leaving headroom for the systemd-boot binary + fallback).
  # Raise only if you enlarge /boot (check `du -sh /boot/EFI/nixos/*` for the
  # real per-gen size).
  boot.loader.systemd-boot.configurationLimit = 2;

  # 8 GB swap so nixos-rebuild's eval/build has headroom on this 8 GB box.
  # The file is created out-of-band with `btrfs filesystem mkswapfile` (NoCOW,
  # hole-free); declaring a `size` here would make NixOS fallocate+mkswap it,
  # which btrfs rejects ("swapon: Invalid argument"). Device-only just activates
  # the existing file at boot. zram adds compressed in-RAM swap on top.
  swapDevices = [ { device = "/swapfile"; } ];
  zramSwap.enable = true;

  # Enable new modular services
  services.custom = {
    # Core infrastructure
    acme.enable = true;
    nginx.enable = true;
    postgres.enable = true;
    fail2ban.enable = true;
    backup = {
      enable = true;
      # Default set. Kept explicit here since this is host-specific backup policy.
      sourceDirectories = [
        "/var/lib/vaultwarden"
        "/var/lib/forgejo"
        "/var/lib/ntfy-sh"
        "/var/lib/taskchampion-sync-server"
      ];
    };

    # Application services
    mail-relay = {
      enable = true;
      rootMailTo = "admin@audacis.net";
    };
    vaultwarden = {
      enable = true;
      smtp.enable = true;
      adminTokenFile = config.sops.secrets."vaultwarden/admin-token".path;
    };
    forgejo = {
      enable = true;
      smtp.enable = true;
      runner = {
        enable = true;
        count = 2;
        # Runner UUIDs are not secret: sudo jq -r .uuid /var/lib/gitea-runner/runner-{0,1}/.runner
        uuids = [
          "REPLACE-ME-runner-0"
          "REPLACE-ME-runner-1"
        ];
        tokenFiles = [
          config.sops.secrets."forgejo/runner-0-token".path
          config.sops.secrets."forgejo/runner-1-token".path
        ];
      };
    };
    freshrss = {
      enable = false;
      passwordFile = config.sops.secrets."freshrss/passphrase".path;
    };
    umami.enable = true;

    taskchampion = {
      enable = true;
      environmentFile = config.sops.secrets."taskchampion/env".path;
    };

    ntfy = {
      enable = true;
      auth.users = [
        {
          username = "philippkuehn";
          passwordFile = config.sops.secrets."ntfy/philippkuehn".path;
          tokenFile = "/var/lib/ntfy-sh/access-token";
          role = "admin";
        }
      ];
    };

    podman-cleanup.enable = true;

    alerts = {
      enable = true;
      ntfyTokenFile = "/var/lib/ntfy-sh/access-token";
    };

    vulnix-scan.enable = true;
  };

  networking = {
    hostName = "netcup";

    dhcpcd = {
      enable = true;
      # netcup offers no IPv6 RA/SLAAC (switched subnet — static config is
      # required), so soliciting routers only spams "no IPv6 Routers available".
      # IPv6 is configured statically below instead.
      IPv6rs = false;
    };

    # netcup routes a static /64 to this vServer; take one address from it and
    # send the default route to the link-local VRRP gateway fe80::1 (reachable
    # on the switched link, though it never advertises itself via RA).
    interfaces.enp7s0.ipv6.addresses = [
      {
        address = "2a03:4000:63:782::1";
        prefixLength = 64;
      }
    ];
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp7s0";
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
      ];
    };
  };

  nix.gc.dates = "daily";

  services = {
    qemuGuest.enable = true;
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "yes";
      };
    };
    journald.settings.Journal.SystemMaxUse = "100M";
  };

  sops.defaultSopsFile = ./secrets.yaml;

  # Secrets consumed by services on this host. Declared here rather than in
  # common/optional/sops.nix so other hosts aren't asked to provision keys
  # their own secrets.yaml doesn't contain.
  sops.secrets = {
    # ntfy-sh and its user-provisioning unit both run as root (the upstream
    # module's DynamicUser is forced off here and no ntfy-sh user exists), so
    # the default root:keys 0400 is what this secret needs.
    "ntfy/philippkuehn" = { };
    # Forgejo runner tokens (raw, no TOKEN= prefix), read by the runner units
    # as systemd credentials, so default root ownership is enough.
    "forgejo/runner-0-token" = { };
    "forgejo/runner-1-token" = { };
  };

  # Per-box SSH keys for the Hetzner storage boxes (used by ssh/backup.nix).
  sops.secrets."storagebox/falkenstein-ssh-key".owner = "phil";
  sops.secrets."storagebox/helsinki-ssh-key".owner = "phil";

  # Vaultwarden /admin panel token (file content: ADMIN_TOKEN=<argon2-hash>).
  # Read by systemd (root) as an EnvironmentFile, so default root ownership is fine.
  sops.secrets."vaultwarden/admin-token" = { };

  # TaskChampion allowed client (file content: CLIENT_ID=<uuid>), read by
  # systemd (root) as an EnvironmentFile.
  sops.secrets."taskchampion/env" = { };

  system.stateVersion = "25.05";
}
