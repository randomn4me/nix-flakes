{
  config,
  lib,
  pkgs,
  ...
}:
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
      tlp.enable = true;
    };

    environment.systemPackages = with pkgs; [ powertop ];

    powerManagement.enable = true;
    powerManagement.powertop.enable = true;

    services.thermald.enable = true;
  };
}
