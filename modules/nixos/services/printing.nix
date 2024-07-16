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
      };

      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
  };
}
