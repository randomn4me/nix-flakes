{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.custom.hedgedoc;
in
{
  options.services.custom.hedgedoc = {
    enable = mkEnableOption "HedgeDoc collaborative markdown editor";

    domain = mkOption {
      type = types.str;
      default = "md.audacis.net";
      description = "Domain name for HedgeDoc";
    };

    port = mkOption {
      type = types.port;
      default = 3333;
      description = "Port for HedgeDoc to listen on";
    };

    allowEmailRegistration = mkOption {
      type = types.bool;
      default = false;
      description = "Allow user registration via email";
    };

    database = {
      username = mkOption {
        type = types.str;
        default = "hedgedoc";
        description = "Database user";
      };

      database = mkOption {
        type = types.str;
        default = "hedgedoc";
        description = "Database name";
      };

      host = mkOption {
        type = types.str;
        default = "/run/postgresql";
        description = "Database host";
      };

      dialect = mkOption {
        type = types.str;
        default = "postgresql";
        description = "Database dialect";
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

    installPackage = mkOption {
      type = types.bool;
      default = true;
      description = "Install HedgeDoc package in system environment";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = mkIf cfg.installPackage [ pkgs.hedgedoc ];

    services.hedgedoc = {
      enable = true;
      settings = {
        allowEmailRegistration = cfg.allowEmailRegistration;
        db = {
          username = cfg.database.username;
          database = cfg.database.database;
          host = cfg.database.host;
          dialect = cfg.database.dialect;
        };
        domain = cfg.domain;
        port = cfg.port;
        useSSL = false;
        protocolUseSSL = true;
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = cfg.nginx.enableACME;
      forceSSL = cfg.nginx.forceSSL;

      locations = mkMerge [
        {
          "/" = {
            proxyPass = "http://localhost:${toString cfg.port}";
            proxyWebsockets = true;
            extraConfig = "proxy_ssl_server_name on;";
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
      ensureDatabases = [ cfg.database.database ];
      ensureUsers = [
        {
          name = cfg.database.username;
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
