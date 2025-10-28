{ config, lib, ... }:

with lib;

let
  cfg = config.services.custom.joshua-dashboard;
in
{
  options.services.custom.joshua-dashboard = {
    enable = mkEnableOption "Joshua dashboard service";

    domain = mkOption {
      type = types.str;
      default = "joshua.peasec.de";
      description = "Domain name for the Joshua dashboard";
    };
  };

  config = mkIf cfg.enable {
    # TODO: This service needs a flake input to be configured
    # services.joshua-dashboard = {
    #   enable = true;
    #   domain = cfg.domain;
    # };
  };
}
