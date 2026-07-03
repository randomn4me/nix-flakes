{ config, lib, ... }:

with lib;

let
  cfg = config.services.custom.vaultwarden;
in
{
  options.services.custom.vaultwarden = {
    enable = mkEnableOption "Vaultwarden password manager";

    domain = mkOption {
      type = types.str;
      default = "vault.audacis.net";
      description = "Domain name for Vaultwarden";
    };

    signupsAllowed = mkOption {
      type = types.bool;
      default = false;
      description = "Allow new user signups";
    };

    adminTokenFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        File containing `ADMIN_TOKEN=<token-or-argon2-hash>`, enabling the
        /admin panel. Passed via environmentFile so it never enters the
        world-readable Nix store. Null disables the admin panel.
      '';
    };

    smtp = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Send mail through the local relay (services.custom.mail-relay).";
      };

      from = mkOption {
        type = types.str;
        default = "noreply@audacis.net";
        description = "From address for Vaultwarden emails.";
      };

      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "SMTP host (the local relay).";
      };

      port = mkOption {
        type = types.port;
        default = 25;
        description = "SMTP port (the local relay).";
      };
    };

    proxyAddress = mkOption {
      type = types.str;
      default = "http://127.0.0.1:8000";
      description = "Internal address Vaultwarden listens on";
    };

    nginx = {
      enableACME = mkOption {
        type = types.bool;
        default = true;
        description = "Enable ACME SSL certificates";
      };

      forceSSL = mkOption {
        type = types.bool;
        default = true;
        description = "Force SSL for all connections";
      };

      disallowRobots = mkOption {
        type = types.bool;
        default = true;
        description = "Disallow search engine robots";
      };
    };
  };

  config = mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      config = mkMerge [
        {
          DOMAIN = "https://${cfg.domain}";
          SIGNUPS_ALLOWED = cfg.signupsAllowed;
        }
        (mkIf cfg.smtp.enable {
          SMTP_HOST = cfg.smtp.host;
          SMTP_PORT = cfg.smtp.port;
          SMTP_SECURITY = "off";
          SMTP_FROM = cfg.smtp.from;
          SMTP_FROM_NAME = "Vaultwarden";
        })
      ];
      environmentFile = mkIf (cfg.adminTokenFile != null) cfg.adminTokenFile;
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = cfg.nginx.enableACME;
      forceSSL = cfg.nginx.forceSSL;
      serverName = cfg.domain;

      locations = mkMerge [
        {
          "/".proxyPass = cfg.proxyAddress;
        }
        (mkIf cfg.nginx.disallowRobots {
          "/robots.txt".extraConfig = ''
            rewrite ^/(.*)  $1;
            return 200 "User-agent: *\nDisallow: /";
          '';
        })
      ];
    };
  };
}
