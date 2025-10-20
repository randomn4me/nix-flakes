{ inputs, outputs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/phil

    ../common/optional/services/fail2ban.nix
    ../common/optional/services/vaultwarden.nix
    ../common/optional/services/taskserver.nix
    ../common/optional/services/forgejo.nix

    ../common/optional/services/blog.nix
    ../common/optional/services/audax-zola.nix

    ../common/optional/services/audax-dashboard.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  security.acme.defaults.email = "admin@audacis.net";

  system.stateVersion = "25.05";
}
