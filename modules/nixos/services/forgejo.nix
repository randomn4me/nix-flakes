{ config, lib, pkgs, ... }:

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

    runner = {
      enable = mkEnableOption "Forgejo Actions runner";

      name = mkOption {
        type = types.str;
        default = config.networking.hostName;
        description = "Name for the runner instance";
      };

      tokenFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to file containing TOKEN=<secret> for runner registration";
      };

      labels = mkOption {
        type = types.listOf types.str;
        default = [
          "docker:docker://node:20-bookworm"
          "ubuntu-latest:docker://node:20-bookworm"
          "ubuntu-22.04:docker://node:20-bookworm"
        ];
        description = "Labels for the runner (format: label:docker://image)";
      };

      hostPackages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          bash
          coreutils
          curl
          gawk
          git
          gnused
          nodejs
          wget
        ];
        description = "Packages available for native host execution";
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
      package = pkgs.forgejo;  # Use latest instead of LTS
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

    # Create gitea-runner user/group early for sops
    users.users.gitea-runner = mkIf cfg.runner.enable {
      isSystemUser = true;
      group = "gitea-runner";
      description = "Gitea Actions runner user";
    };

    users.groups.gitea-runner = mkIf cfg.runner.enable {};

    # Forgejo Actions Runner configuration
    services.gitea-actions-runner = mkIf cfg.runner.enable {
      package = pkgs.forgejo-runner;
      instances.default = {
        enable = true;
        name = cfg.runner.name;
        url = "https://${cfg.domain}";
        tokenFile = cfg.runner.tokenFile;
        labels = cfg.runner.labels;
        hostPackages = cfg.runner.hostPackages;
      };
    };

    # Enable Podman for container-based runners (rootless, daemonless)
    virtualisation.podman = mkIf cfg.runner.enable {
      enable = true;
      dockerCompat = true;  # Creates docker alias for compatibility
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
