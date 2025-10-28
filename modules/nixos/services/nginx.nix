{ config, lib, ... }:

with lib;

let
  cfg = config.services.custom.nginx;
in
{
  options.services.custom.nginx = {
    enable = mkEnableOption "nginx web server";

    recommendedGzipSettings = mkOption {
      type = types.bool;
      default = true;
      description = "Enable recommended gzip settings";
    };

    recommendedTlsSettings = mkOption {
      type = types.bool;
      default = true;
      description = "Enable recommended TLS settings";
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
    services.nginx = {
      enable = true;
      recommendedGzipSettings = cfg.recommendedGzipSettings;
      recommendedTlsSettings = cfg.recommendedTlsSettings;
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall cfg.ports;
  };
}
