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

        # Device runtime power management: TLP only opportunistically touches
        # runtime PM, which leaves most of the PCI tree pinned at
        # power/control=on. Setting it to auto is what gets the Thunderbolt
        # controller and the dGPU into D3cold -- measured >90% of uptime
        # suspended on peasec.
        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";

        # PCIe link state. On peasec these two are a no-op: the ACPI FADT sets
        # NO_ASPM ("FADT indicates ASPM is unsupported, using BIOS
        # configuration"), so the kernel declines to manage ASPM at all and
        # /sys/module/pcie_aspm/parameters/policy stays read-only at [default].
        # Nothing is lost -- the firmware programs the links itself, and as of
        # 2026-09-02 the NVMe link runs ASPM L1 with both the L1.1 and L1.2
        # substates enabled, which is the best state available. Kept for hosts
        # whose firmware does hand ASPM to the OS. Do not reach for
        # pcie_aspm=force here: it takes over an already-correct configuration
        # and buys nothing but a risk of NVMe link instability.
        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersave";

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
