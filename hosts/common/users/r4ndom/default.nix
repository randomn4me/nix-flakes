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

  users.users.r4ndom = {
    isNormalUser = true;
    extraGroups =
      [ "wheel" ]
      ++ ifTheyExist [
        "network"
        "scanner"
        "lp"
        "libvirtd"
        "video"
        "audio"
        "i2c"
      ];

    packages = [ pkgs.home-manager ];
    linger = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEN/2C4ROHUhM1yFxK8vJOIvQh7LHs9nVP+NDceb5cex r4nodm@peasec"
    ];
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs;
    };
    users.r4ndom = import ../../../../home/${config.networking.hostName}.nix;
    backupFileExtension = "backup";
  };

  security.pam.services = {
    swaylock = { };
  };
}
