{ lib, config, ... }:
with lib;

let
  cfg = config.mynixos.powerManagement.auto-cpufreq;
in
{
  options.mynixos.powerManagement.auto-cpufreq.enable = mkEnableOption "Enable auto-cpufreq";

  config = mkIf cfg.enable {
    services = {
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
