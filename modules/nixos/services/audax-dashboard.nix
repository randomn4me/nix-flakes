{ config, lib, ... }:

with lib;

let
  cfg = config.services.custom.audax-dashboard;
in
{
  options.services.custom.audax-dashboard = {
    enable = mkEnableOption "Audax dashboard service";

    domain = mkOption {
      type = types.str;
      default = "dashboard.audax-security.com";
      description = "Domain name for the Audax dashboard";
    };

    acmeEmail = mkOption {
      type = types.str;
      default = "admin@audax-security.com";
      description = "Email address for ACME certificates";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Open ports 80 and 443 in the firewall";
    };

    ports = mkOption {
      type = types.listOf types.port;
      default = [ 80 443 ];
      description = "TCP ports to open in firewall";
    };
  };

  config = mkIf cfg.enable {
    services.audax-dashboard = {
      enable = true;
      domain = cfg.domain;
      acmeEmail = mkDefault cfg.acmeEmail;
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall cfg.ports;
  };
}
