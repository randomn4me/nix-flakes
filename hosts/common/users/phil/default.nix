{ pkgs, config, ... }:
{
  users.users.phil = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "network"
    ];

    packages = [ pkgs.home-manager ];
  };

  home-manager.users.phil = import ../../../../home/phil/${config.networking.hostName}.nix;

  security.pam.services = { swaylock = {}; };
}

