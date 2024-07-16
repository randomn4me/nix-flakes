{ lib, config, ... }:
with lib;

let
  cfg = config.mynixos.powerManagement.auto-cpufreq;
in
{
  options.mynixos.powerManagement.auto-cpufreq = mkEnableOption "Enable auto-cpufreq";

  config = mkIf cfg.enable {
    powerManagement = {
      auto-cpufreq.enable = true;
      auto-cpufreq.settings = {
        battery = {
          governor = "powersave";
          turbo = "auto";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };
  };
}
