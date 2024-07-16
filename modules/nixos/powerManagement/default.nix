{ config, lib, ... }:
with lib;

let
  cfg = config.mynixos.powerManagement;
in
{
  imports = [
    ./auto-cpufreq.nix
    ./tlp.nix
    ./ignoreUSB.nix
  ];

  options.mynixos.powerManagement.enable = mkEnableOption "Enable powermanagement";

  config = mkIf cfg.enable {
    mynixos.powerManagement = {
      auto-cpufreq.enable = true;
      devices = [
        "SK622 Mechanical Keyboard - White Edition"
        "Optical Mouse"
      ];
      tlp.enable = true;
    };
  };
}
