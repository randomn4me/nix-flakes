{
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/r4ndom

    ../common/optional/services/fail2ban.nix
    ../common/optional/services/vaultwarden.nix
    ../common/optional/services/forgejo.nix
  ];

  networking = {
    hostName = "netcup";

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
    # responsible for a safe shutdown of your system, among other features utilized by the SCP
    qemuGuest.enable = true;

    journald.extraConfig = "SystemMaxUse=100M";
  };

  system.stateVersion = "24.11";
}

