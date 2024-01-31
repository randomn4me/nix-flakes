{
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/r4ndom

    ../common/optional/services/fail2ban.nix
    ../common/optional/services/mastodon.nix
    ../common/optional/services/taskserver.nix
    ../common/optional/services/vaultwarden.nix
    #../common/optional/services/anki.nix
  ];

  networking.hostName = "hetzner";

  boot.loader.grub = {
    enable = true;
    devices = [ "/dev/sda" ];
  };

  services = {
    #clamav = {
    #  daemon.enable = true;
    #  updater.enable = true;
    #};
  
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
      };
    };
  };

  # hetzner specific network settings
  systemd.network = {
    enable = true;

    networks."10-wan" = {
      matchConfig.Name = "ens3"; # either ens3 (amd64) or enp1s0 (arm64)
      networkConfig.DHCP = "ipv4";
      address = [ "2a01:4f8:c2c:70e3::1/64" ];
      routes = [ { routeConfig.Gateway = "fe80::1"; } ];
    };
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  system.stateVersion = "23.05";
}
