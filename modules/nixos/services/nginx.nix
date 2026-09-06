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

    hsts = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Send HTTP Strict-Transport-Security on every HTTPS vhost. Required for
          an SSL Labs A+ (a host without it is capped at A), and it closes the
          plain-HTTP window that the port-80 redirect still leaves open.
        '';
      };

      maxAge = mkOption {
        type = types.int;
        default = 63072000; # 2 years; SSL Labs wants at least 180 days
        description = "max-age in seconds";
      };

      includeSubDomains = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Apply the policy to every subdomain. Safe here because every vhost on
          this host is forceSSL; adding an HTTP-only subdomain later would break
          it, so flip this off in that case.
        '';
      };

      preload = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Add the `preload` token, the opt-in for hstspreload.org. Not needed for
          A+ and effectively irreversible (removal takes months to reach users),
          so it stays off until the domain is deliberately submitted.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      recommendedGzipSettings = cfg.recommendedGzipSettings;
      recommendedTlsSettings = cfg.recommendedTlsSettings;

      # http-level add_header is inherited by every vhost that does not set an
      # add_header of its own (nginx replaces, never merges, the inherited set),
      # so this covers all domains on the box at once. If a vhost ever needs its
      # own headers, repeat this line there.
      # The map keeps the header off plain-HTTP responses, where RFC 6797 §7.2
      # says it must not be sent: $scheme http hits no entry, and nginx omits a
      # header whose value is the empty string.
      commonHttpConfig = mkIf cfg.hsts.enable ''
        map $scheme $hsts_header {
          https "max-age=${toString cfg.hsts.maxAge}${optionalString cfg.hsts.includeSubDomains "; includeSubDomains"}${optionalString cfg.hsts.preload "; preload"}";
        }
        add_header Strict-Transport-Security $hsts_header always;
      '';
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall cfg.ports;
  };
}
