{ config, lib, ... }:
with lib;

let
  cfg = config.custom.powerManagement;
in
{
  imports = [
    ./auto-cpufreq.nix
    ./tlp.nix
    ./ignoreUSB.nix
  ];

  options.custom.powerManagement.enable = mkEnableOption "Enable powermanagement";

  config = mkIf cfg.enable {
    custom.powerManagement = {
      auto-cpufreq.enable = true;
      devices = [
        "SK622 Mechanical Keyboard - White Edition"
        "Optical Mouse"
      ];
    };

    environment.systemPackages = with pkgs; [ powertop ];

    services.powerManagement.enable = true;
    services.powerManagement.powertop.enable = true;

    services.thermald.enable = true;
  };
}
