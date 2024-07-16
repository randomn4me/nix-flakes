{ config, lib, ... }:
with lib;

let
  cfg = config.custom.powerManagement.tlp;
in
{
  options.custom.powerManagement.tlp.enable = mkEnableOption "Enable tlp";

  config = mkIf cfg.enable {
    services.tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 60;
        STOP_CHARGE_THRESH_BAT0 = 90;
      };
    };
  };
}
