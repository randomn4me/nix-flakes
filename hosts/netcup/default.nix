{ inputs, outputs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/phil

    inputs.disko.nixosModules.disko
    ./disko.nix
    ../common/optional/services/fail2ban.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking = {
    hostName = "audacis-netcup";
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

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs;
    };
    users.phil = import ../../../../home/netcup.nix;
  };

  system.stateVersion = "25.05";
}
