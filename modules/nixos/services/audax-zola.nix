{ config, lib, ... }:

with lib;

let
  cfg = config.services.custom.audax-zola;
in
{
  options.services.custom.audax-zola = {
    enable = mkEnableOption "Audax Zola static site";

    domain = mkOption {
      type = types.str;
      default = "audax-security.com";
      description = "Domain name for the Audax Zola site";
    };
  };

  config = mkIf cfg.enable {
    services.audax-page = {
      enable = true;
      domain = cfg.domain;
    };
  };
}
