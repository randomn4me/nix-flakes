{
  imports = [
    ../common/global
    ../common/users/r4ndom
  ];

  networking.hostName = "work-server";

  boot.loader.grub = {
    enable = true;
    devices = [ "/dev/sda" ];
  };

  nix.gc.dates = "daily";

  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
    };

    journald.extraConfig = "SystemMaxUse=100M";
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.nameservers = [
    "130.83.22.60"
    "130.83.22.63"
  ];
}
