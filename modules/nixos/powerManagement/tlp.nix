{ config, lib, ... }:
with lib;

let
  cfg = config.custom.powerManagement.tlp;
in
{
  options.custom.powerManagement.tlp = {
    enable = mkEnableOption "Enable tlp";

    batteryCare = mkOption {
      description = ''
        Charge thresholds for BAT0. Keeping the pack between 75% and 80%
        roughly halves calendar ageing compared to charging to 100%; drop
        this to null on a machine that actually needs the full runtime.
      '';
      type = types.nullOr (
        types.submodule {
          options = {
            start = mkOption {
              type = types.ints.between 0 100;
              default = 75;
            };
            stop = mkOption {
              type = types.ints.between 0 100;
              default = 80;
            };
          };
        }
      );
      default = { };
    };

    aggressiveOnBattery = mkOption {
      description = ''
        Clamp turbo and peak p-states while discharging. Saves a few watts
        under load at the cost of a noticeably slower machine on battery.
      '';
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    # nixos-hardware's common/pc/laptop already flips services.tlp.enable on
    # via mkDefault, but leaves the settings empty -- TLP then runs on its
    # built-in defaults, which leave PCIe ASPM, runtime PM and the ThinkPad
    # platform profile untouched. Everything below is what those defaults miss.
    services.tlp = {
      enable = true;
      settings = {
        # DYTC platform profile. Without this the EC sits in "performance"
        # even while discharging, which raises the sustained power floor.
        PLATFORM_PROFILE_ON_AC = "balanced";
        PLATFORM_PROFILE_ON_BAT = "low-power";

        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        # Link-state and device runtime power management: TLP defaults to
        # PCIE_ASPM_ON_BAT=default and only opportunistically touches runtime
        # PM, which leaves most of the PCI tree pinned at power/control=on.
        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersave";
        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";

        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";

        NMI_WATCHDOG = 0;
      }
      // optionalAttrs (cfg.batteryCare != null) {
        START_CHARGE_THRESH_BAT0 = cfg.batteryCare.start;
        STOP_CHARGE_THRESH_BAT0 = cfg.batteryCare.stop;
      }
      // optionalAttrs cfg.aggressiveOnBattery {
        CPU_BOOST_ON_BAT = 0;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 60;
      };
    };
  };
}
