{ config, lib, ... }:
with lib;

let
  cfg = config.mynixos.powerManagement.tlp;
in
{
  options.mynixos.powerManagement.tlp.enable = mkEnableOption "Enable tlp";

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
