{ inputs, outputs, lib, config, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/phil

    ../common/optional/sops.nix

    inputs.audacis-blog.nixosModules.default
    inputs.audax-zola.nixosModules.default
    inputs.code-of-courage.nixosModules.default
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
    forgejo = {
      enable = true;
      runner = {
        enable = true;
        tokenFile = config.sops.secrets."forgejo/runner-connection".path;
      };
    };
    freshrss = {
      enable = false;
      passwordFile = config.sops.secrets."freshrss/passphrase".path;
    };

    # External flake services
    audacis-blog.enable = true;
    audax-zola.enable = true;
    code-of-courage.enable = true;
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

  system.stateVersion = "25.05";
}
