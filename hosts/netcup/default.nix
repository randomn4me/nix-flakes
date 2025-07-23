{
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/phil

    ../common/optional/services/fail2ban.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking = {
    hostName = "netcup";
    firewall.enable = true;
  };

  nix.gc.dates = "daily";

  services = {
    qemuGuest.enable = true;
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
      };
    };
    journald.extraConfig = "SystemMaxUse=100M";
  };

  system.stateVersion = "25.05";
}
