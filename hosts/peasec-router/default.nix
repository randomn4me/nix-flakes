{ inputs, ... }:
{
  imports = [
    ../common/global
    ../common/users/pkuehn
    ../common/global/disko/peasec-router.nix
  ];

  networking = {
    hostName = "peasec-router";

    firewall.enable = true;
    firewall.allowedTCPPorts = [ 22 ];

    nameservers = [
      "130.83.22.60"
      "130.83.22.63"
    ];
  };

  nix.gc.dates = "daily";

  services = {
    openssh = {
      enable = true;
    };

    journald.extraConfig = "SystemMaxUse=100M";
  };

  nixpkgs.hostPlatform = {
    system = "aarch64-linux";
  };

  system.stateVersion = "25.05";
}

