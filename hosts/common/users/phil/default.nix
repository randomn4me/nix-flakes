{ pkgs, inputs, outputs, config, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  users.users.phil = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "network"
    ];

    packages = [ pkgs.home-manager ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users.phil = import ../../../../home/phil/${config.networking.hostName}.nix;
  };

  security.pam.services = { swaylock = {}; };
}

