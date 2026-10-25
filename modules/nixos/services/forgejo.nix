{
  config,
  lib,
  pkgs,
  ...
}:

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

      uuids = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "UUID of each registered runner (from Forgejo or the old .runner file), one per instance";
      };

      tokenFiles = mkOption {
        type = types.listOf types.path;
        default = [ ];
        description = "Files containing the raw runner token (no TOKEN= prefix), one per instance";
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

      proxyTimeout = mkOption {
        type = types.str;
        default = "600s";
        description = ''
          proxy_read_timeout / proxy_send_timeout for the vhost.

          A git smart-HTTP clone of full history (CI `fetch-depth: 0`) makes the
          server enumerate and compress the entire object set before it can emit
          the first byte of the pack. On a large repo that startup easily exceeds
          nginx's default 60s proxy_read_timeout, so nginx gives up mid-transfer
          and returns 504 — the client sees `fatal: expected 'packfile'`. Shallow
          clones respond immediately and are unaffected. Keep this above the
          worst-case time-to-first-byte of upload-pack.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      package = pkgs.forgejo; # Use latest instead of LTS
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
      }
      // lib.optionalAttrs cfg.smtp.enable {
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
      serviceConfig.ExecStartPost =
        let
          dumpDir = config.services.forgejo.dump.backupDir;
          keep = toString cfg.dumpRetentionCount;
        in
        [
          "${pkgs.bash}/bin/bash -c 'ls -1t ${dumpDir}/forgejo-dump-*.zip 2>/dev/null | tail -n +$((${keep}+1)) | xargs -r rm -f'"
        ];
    };

    # Dump the database on every borgmatic run (services.custom.backup), so it is
    # as fresh as the repositories archived next to it instead of lagging up to a
    # day behind in the forgejo-dump zip. Same peer-auth setup as umami.nix.
    services.borgmatic = mkIf (config.services.custom.backup.enable && cfg.databaseType == "postgres") {
      settings.postgresql_databases = [
        {
          name = config.services.forgejo.database.name;
          username = "postgres";
        }
      ];
    };

    assertions = mkIf cfg.runner.enable [
      {
        assertion =
          length cfg.runner.uuids == cfg.runner.count && length cfg.runner.tokenFiles == cfg.runner.count;
        message = "services.custom.forgejo.runner: uuids and tokenFiles need one entry per runner (count = ${toString cfg.runner.count}).";
      }
      {
        assertion = !(any (hasPrefix "REPLACE-ME") cfg.runner.uuids);
        message = "services.custom.forgejo.runner.uuids still contains a placeholder.";
      }
    ];

    # Forgejo Actions Runner configuration
    services.forgejo-runner = mkIf cfg.runner.enable {
      instances = builtins.listToAttrs (
        builtins.genList (i: {
          name = "runner-${toString i}";
          value = {
            enable = true;
            runtimes.podman = true;
            hostPackages = cfg.runner.hostPackages;
            secrets.server.connections.default.token_url = elemAt cfg.runner.tokenFiles i;
            settings = {
              runner.labels = cfg.runner.labels;
              server.connections.default = {
                url = "https://${cfg.domain}";
                uuid = elemAt cfg.runner.uuids i;
              };
              container = {
                options = "-v /run/podman/podman.sock:/var/run/docker.sock --privileged";
                valid_volumes = [
                  "/run/podman/podman.sock"
                  "/var/run/docker.sock"
                ];
              };
            };
          };
        }) cfg.runner.count
      );
    };

    # Enable Podman for container-based runners (rootless, daemonless)
    virtualisation.podman = mkIf cfg.runner.enable {
      enable = true;
      dockerCompat = true; # Creates docker alias for compatibility
      dockerSocket.enable = true;
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = cfg.nginx.forceSSL;
      serverName = cfg.domain;
      enableACME = cfg.nginx.enableACME;

      extraConfig = ''
        client_max_body_size ${cfg.nginx.clientMaxBodySize};

        # Git smart-HTTP over the proxy. A full-history clone (CI fetch-depth: 0)
        # spends a long time counting/compressing objects before the first pack
        # byte; nginx's default 60s proxy_read_timeout fires in that window and
        # returns 504 ("fatal: expected 'packfile'" on the client). Raise the
        # timeouts and stop nginx buffering the (large, streamed) pack so bytes
        # flow through as the upstream produces them.
        proxy_read_timeout ${cfg.nginx.proxyTimeout};
        proxy_send_timeout ${cfg.nginx.proxyTimeout};
        proxy_buffering off;
        proxy_request_buffering off;
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
