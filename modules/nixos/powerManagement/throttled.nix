{ config, lib, ... }:
with lib;

let
  cfg = config.custom.powerManagement.throttled;

  profileModule =
    defaults:
    types.submodule {
      options = {
        pl1 = mkOption {
          description = ''
            Sustained (long-term) package power limit, in watts. This is the
            one that decides how a machine behaves under a build: the cores
            run at whatever frequency fits inside it once PL1_Duration_s has
            elapsed. Setting it below the part's rated TDP makes power, not
            temperature, the binding constraint.
          '';
          type = types.ints.positive;
          default = defaults.pl1;
        };

        pl2 = mkOption {
          description = ''
            Burst (short-term) package power limit, in watts. Applies for
            PL1_Duration_s before the package falls back to `pl1`.
          '';
          type = types.ints.positive;
          default = defaults.pl2;
        };

        pl1Duration = mkOption {
          description = "Seconds spent at `pl2` before `pl1` takes over.";
          type = types.numbers.positive;
          default = 28;
        };

        tripTemp = mkOption {
          description = ''
            Package temperature at which throttled pulls the limits back,
            in degrees Celsius.
          '';
          type = types.ints.between 40 100;
          default = defaults.tripTemp;
        };

        updateRate = mkOption {
          description = "Seconds between throttled re-applying the MSRs.";
          type = types.ints.positive;
          default = defaults.updateRate;
        };
      };
    };

  renderProfile = section: p: ''
    [${section}]
    Update_Rate_s: ${toString p.updateRate}
    PL1_Tdp_W: ${toString p.pl1}
    PL1_Duration_s: ${toString p.pl1Duration}
    PL2_Tdp_W: ${toString p.pl2}
    PL2_Duration_S: 0.002
    Trip_Temp_C: ${toString p.tripTemp}
    cTDP: 0
    Disable_BDPROCHOT: False
  '';

  # Undervolting is deliberately not exposed. It needs per-chip validation and
  # a bad offset shows up as silent corruption or a hang under load, not as an
  # error -- not something a shared module should make easy to turn on.
  noUndervolt = section: ''
    [UNDERVOLT.${section}]
    CORE: 0
    GPU: 0
    CACHE: 0
    UNCORE: 0
    ANALOGIO: 0
  '';
in
{
  options.custom.powerManagement.throttled = {
    enable = mkOption {
      description = ''
        Supply a tuned config to `services.throttled`.

        Enabling the service itself is left to the hardware module (for
        ThinkPads, nixos-hardware turns it on by `mkDefault`), so this
        follows it by default. Its stock config permits PL1=29W/PL2=44W on
        battery -- roughly double a U-series part's rated TDP, enough for a
        single build to pull 30W+ out of the pack -- so a host running
        throttled without this is the case worth avoiding.
      '';
      type = types.bool;
      default = config.services.throttled.enable;
      defaultText = literalExpression "config.services.throttled.enable";
    };

    battery = mkOption {
      description = "Package power limits while discharging.";
      type = profileModule {
        pl1 = 15;
        pl2 = 25;
        tripTemp = 80;
        updateRate = 30;
      };
      default = { };
    };

    ac = mkOption {
      description = "Package power limits while on mains.";
      type = profileModule {
        pl1 = 25;
        pl2 = 44;
        tripTemp = 95;
        updateRate = 5;
      };
      default = { };
    };
  };

  config = mkIf cfg.enable {
    # Defaults suit a 15W U-series ThinkPad. Battery sits at the rated 15W:
    # below that, power rather than temperature becomes the binding constraint
    # -- at PL1=12W the cores settled at exactly 800 MHz under sustained
    # all-core load at 45-48 C, nowhere near the 80 C trip, decaying in step
    # with PL1_Duration_s. AC keeps headroom above the rating, which is what
    # makes a long build audible but keeps it short.
    # Joined rather than interpolated so the rendered file ends with exactly
    # one newline, as throttled's own sample config does.
    services.throttled.extraConfig = concatStringsSep "\n" [
      ''
        [GENERAL]
        Enabled: True
        Sysfs_Power_Path: /sys/class/power_supply/AC*/online
        Autoreload: True
      ''
      (renderProfile "BATTERY" cfg.battery)
      (renderProfile "AC" cfg.ac)
      (noUndervolt "BATTERY")
      (noUndervolt "AC")
    ];

    assertions = [
      {
        assertion = cfg.battery.pl2 >= cfg.battery.pl1 && cfg.ac.pl2 >= cfg.ac.pl1;
        message = "custom.powerManagement.throttled: pl2 is the burst limit and must be >= pl1.";
      }
    ];
  };
}
