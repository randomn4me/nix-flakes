{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.custom.podman-cleanup;
in
{
  options.services.custom.podman-cleanup = {
    enable = mkEnableOption "periodic Podman garbage collection";

    calendar = mkOption {
      type = types.str;
      default = "weekly";
      description = "Systemd calendar expression for cleanup schedule";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.podman-cleanup = {
      description = "Podman system cleanup";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.podman}/bin/podman system prune --all --force --volumes";
      };
    };

    systemd.timers.podman-cleanup = {
      description = "Periodic Podman garbage collection";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.calendar;
        Persistent = true;
        RandomizedDelaySec = "6h";
      };
    };
  };
}
