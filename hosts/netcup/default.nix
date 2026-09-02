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

    # External flake-based services — only this host deploys them, and only
    # this host should have to reach their private git remotes.
    ../../modules/nixos/services/audacis-blog.nix
    ../../modules/nixos/services/serify-page.nix
    ../../modules/nixos/services/code-of-courage.nix
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
      # Default set plus Zulip's nightly tarball (DB + config) and its uploaded
      # files. Kept explicit here since this is host-specific backup policy.
      sourceDirectories = [
        "/var/lib/vaultwarden"
        "/var/lib/forgejo"
        "/var/lib/ntfy-sh"
        "/var/lib/zulip/backups"
        "/var/lib/zulip/app"
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
        tokenFile = config.sops.secrets."forgejo/runner-connection".path;
      };
    };
    freshrss = {
      enable = false;
      passwordFile = config.sops.secrets."freshrss/passphrase".path;
    };
    zulip = {
      enable = true;
      domain = "chat.serify.eu";
    };

    # External flake services
    audacis-blog.enable = true;
    serify-page = {
      enable = true;
      redirectDomains = [
        "acipra.de"
        "acipra.com"
        "serify.de"
        "serify.ai"
      ];
    };
    code-of-courage.enable = true;

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
    journald.extraConfig = "SystemMaxUse=100M";
  };

  sops.defaultSopsFile = ./secrets.yaml;

  # Secrets consumed by services on this host. Declared here rather than in
  # common/optional/sops.nix so other hosts aren't asked to provision keys
  # their own secrets.yaml doesn't contain.
  sops.secrets = {
    "joshua/passphrase" = {
      owner = "nginx";
      group = "nginx";
      mode = "0440";
    };
    "joshua/username" = {
      owner = "nginx";
      group = "nginx";
      mode = "0440";
    };
    "ntfy/philippkuehn" = {
      owner = "ntfy-sh";
      group = "ntfy-sh";
      mode = "0440";
    };
    # Forgejo runner token (format: TOKEN=<secret>)
    "forgejo/runner-connection" = {
      owner = "gitea-runner";
      group = "gitea-runner";
      mode = "0440";
    };
  };

  # Per-box SSH keys for the Hetzner storage boxes (used by ssh/backup.nix).
  sops.secrets."storagebox/falkenstein-ssh-key".owner = "phil";
  sops.secrets."storagebox/helsinki-ssh-key".owner = "phil";

  # Vaultwarden /admin panel token (file content: ADMIN_TOKEN=<argon2-hash>).
  # Read by systemd (root) as an EnvironmentFile, so default root ownership is fine.
  sops.secrets."vaultwarden/admin-token" = { };

  system.stateVersion = "25.05";
}
