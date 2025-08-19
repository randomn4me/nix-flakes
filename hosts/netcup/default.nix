{ inputs, outputs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/phil

    ../common/optional/services/fail2ban.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "audacis-netcup";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
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
        PasswordAuthentication = false;
        PermitRootLogin = "yes";
      };
    };
    journald.extraConfig = "SystemMaxUse=100M";
  };

  system.stateVersion = "25.05";
}
