{
  pkgs,
  inputs,
  outputs,
  config,
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEN/2C4ROHUhM1yFxK8vJOIvQh7LHs9nVP+NDceb5cex nix-laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFYBykZ07Oy9hAvGoRKxQsofN0zANFENiZ4Cko6FVeGK macbook"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJQIwKi8ikDwdklCKFtcca8UENcBZg1V9jFVZcJheOl phone"
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
