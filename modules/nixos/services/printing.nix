{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.custom.printing;
in
{
  options.custom.printing = {
    enable = mkEnableOption "Enable printing";
    drivers = mkOption {
      description = "Package list of printer drivers";
      example = [
        pkgs.cups-kyodialog
        pkgs.mfcj6510dwlpr
      ];
      type = types.listOf types.package;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    services = {
      printing = {
        enable = true;
        drivers = cfg.drivers;
        # Socket-activated: cupsd starts on the first print job instead of
        # sitting resident for a printer that is used a few times a week.
        startWhenNeeded = true;
      };

      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };

    # cups-browsed polls for remote print queues and is pulled in
    # unconditionally by the avahi above. Queues here are configured
    # explicitly, so it only costs wakeups.
    systemd.services.cups-browsed.enable = false;
  };
}
