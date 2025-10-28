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
      config = {
        SIGNUPS_ALLOWED = cfg.signupsAllowed;
      };
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
