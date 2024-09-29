{ lib, config, ... }:
with lib;

let
  cfg = config.custom.powerManagement.auto-cpufreq;
in
{
  options.custom.powerManagement.auto-cpufreq.enable = mkEnableOption "Enable auto-cpufreq";

  config = mkIf cfg.enable {
    services = {
      auto-cpufreq.enable = true;
      auto-cpufreq.settings = {
        battery = {
          governor = "powersave";
          turbo = "auto";
        };
        charger = {
          governor = "default";
          turbo = "auto";
        };
      };
    };
  };
}
