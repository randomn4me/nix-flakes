{ config, lib, ... }:

with lib;

let
  cfg = config.services.custom.audax-page;
in
{
  options.services.custom.audax-page = {
    enable = mkEnableOption "Audax page service";

    domain = mkOption {
      type = types.str;
      default = "audax-security.com";
      description = "Domain name for the Audax page";
    };
  };

  config = mkIf cfg.enable {
    services.audax-page = {
      enable = true;
      domain = cfg.domain;
    };
  };
}
