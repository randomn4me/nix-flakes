{
  pkgs,
  inputs,
  outputs,
  config,
  lib,
  ...
}:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  users.users.phil = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ]
    ++ ifTheyExist [
      "networkmanager"
      "scanner"
      "lp"
      "libvirtd"
      "video"
      "audio"
      "vboxusers"
      "adbusers"
      "i2c"

      # zmk
      "uucp"
      "dialout"
    ];

    packages = [ pkgs.home-manager ];
    linger = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEN/2C4ROHUhM1yFxK8vJOIvQh7LHs9nVP+NDceb5cex r4ndom@peasec"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKluBaVeaUkcr8U5ZF5YTlsyjfUCG0lQkfWrzKVbzM6y pkuehn@kuehn-macbookpro.local"
    ];
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs;
    };
    users.phil = import ../../../../home/${config.networking.hostName}.nix;
  };

  security.pam.services = {
    swaylock = { };
  };
}
