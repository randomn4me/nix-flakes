{ pkgs, inputs, outputs, config, osConfig, ... }:
let
  ifTheyExist = groups:
    builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  users.users.r4ndom = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]
      ++ ifTheyExist [ "network" "scanner" "lp" "libvirtd" "video" "audio" ];

    packages = [ pkgs.home-manager ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users.r4ndom = import ../../../../home/${config.networking.hostName}.nix;
  };

  security.pam.services = { swaylock = { }; };
}

