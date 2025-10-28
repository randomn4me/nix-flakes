{ config, lib, ... }:

with lib;

let
  cfg = config.services.custom.acme;
in
{
  options.services.custom.acme = {
    enable = mkEnableOption "ACME SSL certificate management";

    email = mkOption {
      type = types.str;
      default = "admin@audacis.net";
      description = "Email address for ACME registration";
    };

    acceptTerms = mkOption {
      type = types.bool;
      default = true;
      description = "Accept ACME terms of service";
    };
  };

  config = mkIf cfg.enable {
    security.acme = {
      acceptTerms = cfg.acceptTerms;
      defaults.email = cfg.email;
    };
  };
}
