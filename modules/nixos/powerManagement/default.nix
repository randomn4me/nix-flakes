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
    # TLP only. auto-cpufreq drives the governor and EPP too, so running both
    # means two daemons fighting over the same knobs -- enable
    # custom.powerManagement.auto-cpufreq explicitly (and tlp not at all) if
    # you ever want to swap.
    custom.powerManagement.tlp.enable = mkDefault true;

    environment.systemPackages = with pkgs; [ powertop ];

    powerManagement.enable = true;

    # TLP's RUNTIME_PM_ON_BAT already covers what powertop --auto-tune does,
    # and autotune additionally suspends USB input devices (hence
    # ./ignoreUSB.nix). Leave it to TLP unless a host opts back in.
    powerManagement.powertop.enable = mkDefault false;

    # thermald and nixos-hardware's throttled both write the same RAPL/MSR
    # registers; on a ThinkPad throttled is the one that matters, so thermald
    # stays off wherever it is running.
    services.thermald.enable = mkDefault (!config.services.throttled.enable);

    assertions = [
      {
        assertion = !(config.services.tlp.enable && config.services.auto-cpufreq.enable);
        message = "custom.powerManagement: tlp and auto-cpufreq both manage the cpu governor; enable only one.";
      }
      {
        assertion = !(config.services.thermald.enable && config.services.throttled.enable);
        message = "custom.powerManagement: thermald and throttled both write RAPL MSRs; enable only one.";
      }
    ];
  };
}
