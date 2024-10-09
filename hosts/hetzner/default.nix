{
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/r4ndom

    ../common/optional/services/fail2ban.nix
    ../common/optional/services/vaultwarden.nix
    ../common/optional/services/forgejo.nix
    ../common/optional/services/taskserver.nix
  ];

  networking = {
    hostName = "hetzner";

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  boot.loader.grub = {
    enable = true;
    devices = [ "/dev/sda" ];
  };

  nix.gc.dates = "daily";

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
      };
    };

    journald.extraConfig = "SystemMaxUse=100M";
  };

  # hetzner specific network settings
  systemd.network = {
    enable = true;

    networks."10-wan" = {
      matchConfig.Name = "ens3"; # either ens3 (amd64) or enp1s0 (arm64)
      networkConfig.DHCP = "ipv4";
      address = [ "2a01:4f8:c2c:70e3::1/64" ];
      routes = [ { Gateway = "fe80::1"; } ];
    };
  };

  system.stateVersion = "23.11";
}
