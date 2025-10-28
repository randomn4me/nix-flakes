{ config, lib, ... }:

with lib;

let
  cfg = config.services.custom.forgejo;
in
{
  options.services.custom.forgejo = {
    enable = mkEnableOption "Forgejo git forge";

    domain = mkOption {
      type = types.str;
      default = "git.audacis.net";
      description = "Domain name for Forgejo";
    };

    databaseType = mkOption {
      type = types.str;
      default = "postgres";
      description = "Database type (postgres, mysql, sqlite3)";
    };

    enableDump = mkOption {
      type = types.bool;
      default = true;
      description = "Enable automatic backups";
    };

    enableLFS = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Git Large File Storage";
    };

    disableRegistration = mkOption {
      type = types.bool;
      default = false;
      description = "Disable user registration";
    };

    actions = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Forgejo Actions (CI/CD)";
      };

      defaultActionsUrl = mkOption {
        type = types.str;
        default = "github";
        description = "Default URL for fetching actions";
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

      clientMaxBodySize = mkOption {
        type = types.str;
        default = "512M";
        description = "Maximum size for client uploads";
      };
    };
  };

  config = mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      database.type = cfg.databaseType;
      dump.enable = cfg.enableDump;
      lfs.enable = cfg.enableLFS;

      settings = {
        server = {
          DOMAIN = cfg.domain;
          ROOT_URL = "https://${cfg.domain}";
        };

        service.DISABLE_REGISTRATION = cfg.disableRegistration;

        actions = {
          ENABLED = cfg.actions.enable;
          DEFAULT_ACTIONS_URL = cfg.actions.defaultActionsUrl;
        };
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = cfg.nginx.forceSSL;
      serverName = cfg.domain;
      enableACME = cfg.nginx.enableACME;

      extraConfig = ''
        client_max_body_size ${cfg.nginx.clientMaxBodySize};
      '';

      locations = mkMerge [
        {
          "/".proxyPass = "http://localhost:${toString config.services.forgejo.settings.server.HTTP_PORT}";
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
