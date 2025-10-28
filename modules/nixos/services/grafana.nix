{ config, lib, ... }:

with lib;

let
  cfg = config.services.custom.grafana;
in
{
  options.services.custom.grafana = {
    enable = mkEnableOption "Grafana monitoring dashboard";

    domain = mkOption {
      type = types.str;
      default = "grafana.audacis.net";
      description = "Domain name for Grafana";
    };

    port = mkOption {
      type = types.port;
      default = 3000;
      description = "Port for Grafana to listen on";
    };

    httpAddr = mkOption {
      type = types.str;
      default = "localhost";
      description = "Address for Grafana to bind to";
    };

    database = {
      user = mkOption {
        type = types.str;
        default = "grafana";
        description = "Database user";
      };

      name = mkOption {
        type = types.str;
        default = "grafana";
        description = "Database name";
      };

      type = mkOption {
        type = types.str;
        default = "postgres";
        description = "Database type";
      };
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

    setupPostgres = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically setup PostgreSQL database and user";
    };
  };

  config = mkIf cfg.enable {
    services.grafana = {
      enable = true;
      settings = {
        database = {
          user = cfg.database.user;
          name = cfg.database.name;
          type = cfg.database.type;
        };
        server = {
          http_addr = cfg.httpAddr;
          http_port = cfg.port;
          domain = cfg.domain;
          serve_from_sub_path = true;
        };
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = cfg.nginx.enableACME;
      forceSSL = cfg.nginx.forceSSL;

      locations = mkMerge [
        {
          "/" = {
            proxyPass = "http://${config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };
        }
        (mkIf cfg.nginx.disallowRobots {
          "/robots.txt".extraConfig = ''
            rewrite ^/(.*)  $1;
            return 200 "User-agent: *\nDisallow: /";
          '';
        })
      ];
    };

    services.postgresql = mkIf cfg.setupPostgres {
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [
        {
          name = cfg.database.user;
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
