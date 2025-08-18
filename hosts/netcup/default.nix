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

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKluBaVeaUkcr8U5ZF5YTlsyjfUCG0lQkfWrzKVbzM6y"
  ];

  services = {
    qemuGuest.enable = true;
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = "no";
        PermitRootLogin = "yes";
      };
    };
    journald.extraConfig = "SystemMaxUse=100M";
  };

  system.stateVersion = "25.05";
}
