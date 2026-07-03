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

    dumpRetentionCount = mkOption {
      type = types.int;
      default = 7;
      description = "Number of dump archives to retain; older ones are deleted after each dump";
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

    smtp = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Send mail through the local relay (services.custom.mail-relay).";
      };

      from = mkOption {
        type = types.str;
        default = "noreply@audacis.net";
        description = "From address for Forgejo emails.";
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

      count = mkOption {
        type = types.int;
        default = 1;
        description = "Number of parallel runner instances";
      };

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
          "docker:docker://catthehacker/ubuntu:act-latest"
          "ubuntu-latest:docker://catthehacker/ubuntu:act-latest"
          "ubuntu-22.04:docker://catthehacker/ubuntu:act-latest"
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
        service.REQUIRE_SIGNIN_VIEW = false;

        actions = {
          ENABLED = cfg.actions.enable;
          DEFAULT_ACTIONS_URL = cfg.actions.defaultActionsUrl;
        };
      } // lib.optionalAttrs cfg.smtp.enable {
        mailer = {
          ENABLED = true;
          PROTOCOL = "smtp";
          SMTP_ADDR = cfg.smtp.host;
          SMTP_PORT = cfg.smtp.port;
          FROM = cfg.smtp.from;
        };
      };
    };

    systemd.services.forgejo-dump = mkIf cfg.enableDump {
      serviceConfig.ExecStartPost = let
        dumpDir = config.services.forgejo.dump.backupDir;
        keep = toString cfg.dumpRetentionCount;
      in [
        "${pkgs.bash}/bin/bash -c 'ls -1t ${dumpDir}/forgejo-dump-*.zip 2>/dev/null | tail -n +$((${keep}+1)) | xargs -r rm -f'"
      ];
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
      instances = builtins.listToAttrs (builtins.genList (i: {
        name = "runner-${toString i}";
        value = {
          enable = true;
          name = "${cfg.runner.name}-${toString i}";
          url = "https://${cfg.domain}";
          tokenFile = cfg.runner.tokenFile;
          labels = cfg.runner.labels;
          hostPackages = cfg.runner.hostPackages;
          settings = {
            container = {
              options = "-v /run/podman/podman.sock:/var/run/docker.sock --privileged";
              valid_volumes = [ "/run/podman/podman.sock" "/var/run/docker.sock" ];
            };
          };
        };
      }) cfg.runner.count);
    };

    # Enable Podman for container-based runners (rootless, daemonless)
    virtualisation.podman = mkIf cfg.runner.enable {
      enable = true;
      dockerCompat = true;  # Creates docker alias for compatibility
      dockerSocket.enable = true;
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
