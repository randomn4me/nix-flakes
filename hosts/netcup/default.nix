{ inputs, outputs, lib, config, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/phil

    ../common/optional/sops.nix

    # Import external flake modules
    inputs.audacis-blog.nixosModules.default
    inputs.audax-zola.nixosModules.default
    inputs.audax-dashboard.nixosModules.default
    inputs.joshua-dashboard.nixosModules.default

    # OLD IMPORTS - keeping for reference during testing
    # ../common/optional/services/fail2ban.nix
    # ../common/optional/services/vaultwarden.nix
    # ../common/optional/services/forgejo.nix
    # ../common/optional/services/freshrss.nix
    # ../common/optional/services/blog.nix
    # ../common/optional/services/audax-zola.nix
    # ../common/optional/services/audax-dashboard.nix
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

    # Application services
    vaultwarden.enable = true;
    forgejo.enable = true;
    freshrss = {
      enable = true;
      defaultUser = "admin";
      passwordFile = config.sops.secrets."freshrss/passphrase".path;
    };

    # External flake services
    audacis-blog.enable = true;
    audax-zola.enable = true;
  };

  # Configure audax-dashboard with sops secrets
  services.audax-dashboard = {
    enable = true;
    domain = "dashboard.audax-security.com";
    acmeEmail = "admin@audax-security.com";

    # Use sops-managed secrets for API keys and password
    nvdApiKeyFile = "/run/secrets/audax-dashboard/nvd-api-key";
    threatfoxApiKeyFile = "/run/secrets/audax-dashboard/threatfox-api-key";
    dashboardPasswordFile = "/run/secrets/audax-dashboard/dashboard-passphrase";
  };

  # Configure joshua-dashboard (wargame simulation dashboard)
  services.joshua-dashboard = {
    enable = true;
    domain = "joshua.peasec.de";
    usernameFile = config.sops.secrets."joshua/username".path;
    passwordFile = config.sops.secrets."joshua/passphrase".path;
  };

  networking = {
    hostName = "netcup";

    dhcpcd = {
      enable = true;
      IPv6rs = true;
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  nix.gc.dates = "daily";

  services = {
    qemuGuest.enable = true;
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "yes";
      };
    };
    journald.extraConfig = "SystemMaxUse=100M";
  };

  # Override sops defaultSopsFile to use host-specific secrets
  sops.defaultSopsFile = lib.mkForce ./secrets.yaml;

  system.stateVersion = "25.05";
}
