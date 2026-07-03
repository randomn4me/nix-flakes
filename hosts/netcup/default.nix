{ inputs, outputs, lib, config, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/phil

    ../common/optional/sops.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable new modular services
  services.custom = {
    # Core infrastructure
    acme.enable = true;
    nginx.enable = true;
    postgres.enable = true;
    fail2ban.enable = true;
    backup.enable = true;

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

    # External flake services
    audacis-blog.enable = true;
    serify-page = {
      enable = true;
      redirectDomains = [ "acipra.de" "acipra.com" "serify.de" "serify.ai" ];
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
      IPv6rs = true;
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
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

  # Override sops defaultSopsFile to use host-specific secrets
  sops.defaultSopsFile = lib.mkForce ./secrets.yaml;

  # Per-box SSH keys for the Hetzner storage boxes (used by ssh/backup.nix).
  sops.secrets."storagebox/falkenstein-ssh-key".owner = "phil";
  sops.secrets."storagebox/helsinki-ssh-key".owner = "phil";

  # Vaultwarden /admin panel token (file content: ADMIN_TOKEN=<argon2-hash>).
  # Read by systemd (root) as an EnvironmentFile, so default root ownership is fine.
  sops.secrets."vaultwarden/admin-token" = { };

  system.stateVersion = "25.05";
}
