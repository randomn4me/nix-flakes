{ pkgs, inputs, outputs, config, ... }:
let
  ifTheyExist = groups:
    builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  users.users.phil = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" ]
      ++ ifTheyExist [ "network" "scanner" "lp" "libvirtd" ];

    packages = [ pkgs.home-manager ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users.phil = import ../../../../home/phil/${config.networking.hostName}.nix;
  };

  security.pam.services = { swaylock = { }; };
}

