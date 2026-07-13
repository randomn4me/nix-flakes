{ config, lib, pkgs, ... }:

with lib;

# Zulip team chat, run as the upstream five-container stack under podman and
# fronted by the host nginx.
#
# Why containers and not a native module: Zulip has no server package/module in
# nixpkgs (the request was closed "not planned") and its own installer insists
# on owning the whole machine (apt-installs its own nginx/PostgreSQL/Redis). So
# the NixOS-idiomatic path for un-packaged software is used instead: the images
# are declared here via virtualisation.oci-containers, pinned by tag, wired to
# sops secrets and the host nginx, and managed by nixos-rebuild like everything
# else. This mirrors the upstream compose.yaml faithfully:
#
#   database   zulip/zulip-postgresql:14   (its OWN postgres, with pgroonga —
#                                            NOT the shared services.postgres)
#   memcached  memcached:alpine
#   rabbitmq   rabbitmq:4.2
#   redis      redis:alpine
#   zulip      ghcr.io/zulip/zulip-server  (Django/Tornado app; serves HTTP :80)
#
# TLS is terminated by the host nginx (ACME), which reverse-proxies to the app
# container on loopback; the container serves plain HTTP internally and trusts
# the proxy's X-Forwarded-* headers (TRUST_GATEWAY_IP). Data lives in host bind
# mounts under dataDir (not named podman volumes) so borg can back it up and the
# weekly `podman system prune --volumes` can never reap it.

let
  cfg = config.services.custom.zulip;
  backend = config.virtualisation.oci-containers.backend;

  # Container names are prefixed to stay collision-free on a host that already
  # runs other podman containers (Forgejo CI). Inside the private `zulip`
  # network each is *also* reachable under the short alias the app expects
  # (database/memcached/rabbitmq/redis), so the SETTING_* hostnames match
  # upstream's compose unchanged.
  serviceNames = [ "zulip-database" "zulip-memcached" "zulip-rabbitmq" "zulip-redis" "zulip" ];
  unitOf = n: "${backend}-${n}.service";

  # Entry-point scripts, ported verbatim from upstream compose.yaml (compose's
  # `$$` — a literal `$` — becomes a single `$` here). We override the image
  # entrypoint with `/bin/sh -euc <script>`, which is equivalent to how compose
  # runs them through the image's own docker-entrypoint.sh. Passwords arrive as
  # env vars from the sops-rendered env files (see environmentFiles), so nothing
  # secret is ever baked into the store.
  memcachedCmd = ''
    echo 'mech_list: plain' > "$SASL_CONF_PATH"
    printf 'zulip@%s:%s\n' "$HOSTNAME" "$MEMCACHED_PASSWORD" > "$MEMCACHED_SASL_PWDB"
    printf 'zulip@localhost:%s\n' "$MEMCACHED_PASSWORD" >> "$MEMCACHED_SASL_PWDB"
    exec memcached -S
  '';

  rabbitmqCmd = ''
    echo 'default_user = $(RABBITMQ_DEFAULT_USER)' >> /etc/rabbitmq/rabbitmq.conf
    echo 'default_pass = $(RABBITMQ_DEFAULT_PASS)' >> /etc/rabbitmq/rabbitmq.conf
    exec docker-entrypoint.sh rabbitmq-server
  '';

  redisCmd = ''
    exec /usr/local/bin/docker-entrypoint.sh --requirepass "$REDIS_PASSWORD"
  '';
in
{
  options.services.custom.zulip = {
    enable = mkEnableOption "Zulip team chat (containerised stack behind nginx)";

    domain = mkOption {
      type = types.str;
      default = "chat.audacis.net";
      description = "External hostname Zulip is served on (its EXTERNAL_HOST).";
    };

    adminEmail = mkOption {
      type = types.str;
      default = "admin@audacis.net";
      description = "ZULIP_ADMINISTRATOR — receives server error reports.";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/zulip";
      description = ''
        Base directory for the stack's persistent state. Each service gets a
        host-path bind mount below here (postgresql/, rabbitmq/, redis/, app/)
        plus a backups/ directory for the nightly tarball. Host paths (rather
        than named volumes) keep the data visible to borg and safe from
        `podman system prune --volumes`.
      '';
    };

    httpPort = mkOption {
      type = types.port;
      default = 8080;
      description = ''
        Loopback port the app container publishes its plain-HTTP :80 on. The
        host nginx proxies to 127.0.0.1:<this>. Never exposed to the network.
      '';
    };

    images = {
      zulip = mkOption {
        type = types.str;
        default = "ghcr.io/zulip/zulip-server:12.1-0";
        description = "Zulip application server image (multi-arch: amd64 + arm64).";
      };
      postgres = mkOption {
        type = types.str;
        default = "zulip/zulip-postgresql:14";
        description = "Zulip's customised PostgreSQL image (bundles pgroonga).";
      };
      memcached = mkOption {
        type = types.str;
        default = "memcached:alpine";
        description = "memcached image.";
      };
      rabbitmq = mkOption {
        type = types.str;
        default = "rabbitmq:4.2";
        description = "RabbitMQ image.";
      };
      redis = mkOption {
        type = types.str;
        default = "redis:alpine";
        description = "Redis image.";
      };
    };

    smtp = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Send outgoing mail (invites, notifications) via the same upstream
          smarthost services.custom.mail-relay authenticates to, reusing its
          credentials. Requires services.custom.mail-relay to be enabled.
        '';
      };

      host = mkOption {
        type = types.str;
        default = config.services.custom.mail-relay.relayHost;
        description = "SMTP submission host (defaults to the mail-relay smarthost).";
      };

      port = mkOption {
        type = types.port;
        default = config.services.custom.mail-relay.relayPort;
        description = "SMTP submission port (STARTTLS).";
      };

      user = mkOption {
        type = types.str;
        default = config.services.custom.mail-relay.authUser;
        description = "SMTP auth user (defaults to the mail-relay auth user).";
      };

      from = mkOption {
        type = types.str;
        default = config.services.custom.mail-relay.fromAddress;
        description = "NOREPLY_EMAIL_ADDRESS / envelope sender for Zulip mail.";
      };
    };

    clientMaxBodySize = mkOption {
      type = types.str;
      default = "128M";
      description = "nginx upload cap for the Zulip vhost (message file uploads).";
    };

    backup = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Run a nightly `manage.py backup` producing a consistent tarball
          (DB dump + config) under dataDir/backups. Add that directory (and
          dataDir/app for uploaded files) to services.custom.backup so borg
          ships it offsite.
        '';
      };

      time = mkOption {
        type = types.str;
        default = "03:30";
        description = "OnCalendar expression for the nightly backup.";
      };
    };

    extraSettings = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = { MAX_MESSAGE_LENGTH = "20000"; };
      description = "Extra Zulip settings.py values, passed as SETTING_<key> env vars.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.smtp.enable || config.services.custom.mail-relay.enable;
        message = ''
          services.custom.zulip.smtp reuses the mail-relay smarthost password
          (sops "mail-relay/password"). Enable services.custom.mail-relay, or
          set services.custom.zulip.smtp.enable = false.
        '';
      }
    ];

    virtualisation.podman.enable = mkDefault true;
    virtualisation.oci-containers.backend = mkDefault "podman";

    # ---- secrets -----------------------------------------------------------
    # Internal service passwords + the Django secret key. These are box-local
    # random tokens with no meaning off the machine, but they live in sops (not
    # auto-generated) so a rebuild on a fresh host restores identical values and
    # the `manage.py restore` tarball lines up with the running services. Add
    # them once with:  sops hosts/netcup/secrets.yaml  (see NOTES at bottom).
    sops.secrets = {
      "zulip/postgres-password" = { };
      "zulip/memcached-password" = { };
      "zulip/rabbitmq-password" = { };
      "zulip/redis-password" = { };
      "zulip/secret-key" = { };
    };

    # sops renders these KEY=VALUE env files outside the store (root:0400);
    # podman (rootful) reads them at container start via --env-file. The values
    # never touch the Nix store or `podman inspect`-able command lines.
    sops.templates."zulip-database.env".content =
      "POSTGRES_PASSWORD=${config.sops.placeholder."zulip/postgres-password"}\n";
    sops.templates."zulip-memcached.env".content =
      "MEMCACHED_PASSWORD=${config.sops.placeholder."zulip/memcached-password"}\n";
    sops.templates."zulip-rabbitmq.env".content =
      "RABBITMQ_DEFAULT_PASS=${config.sops.placeholder."zulip/rabbitmq-password"}\n";
    sops.templates."zulip-redis.env".content =
      "REDIS_PASSWORD=${config.sops.placeholder."zulip/redis-password"}\n";
    # The app needs every service password (to connect) plus its own secret key
    # and, optionally, the SMTP password (reused from mail-relay).
    sops.templates."zulip-app.env".content =
      concatStringsSep "\n" ([
        "SECRETS_postgres_password=${config.sops.placeholder."zulip/postgres-password"}"
        "SECRETS_memcached_password=${config.sops.placeholder."zulip/memcached-password"}"
        "SECRETS_rabbitmq_password=${config.sops.placeholder."zulip/rabbitmq-password"}"
        "SECRETS_redis_password=${config.sops.placeholder."zulip/redis-password"}"
        "SECRETS_secret_key=${config.sops.placeholder."zulip/secret-key"}"
      ] ++ optional cfg.smtp.enable
        "SECRETS_email_password=${config.sops.placeholder."mail-relay/password"}"
      ) + "\n";

    # ---- persistent state directories --------------------------------------
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 root root -"
      "d ${cfg.dataDir}/postgresql 0700 root root -"
      "d ${cfg.dataDir}/rabbitmq 0750 root root -"
      "d ${cfg.dataDir}/redis 0750 root root -"
      "d ${cfg.dataDir}/app 0750 root root -"
      "d ${cfg.dataDir}/backups 0750 root root -"
    ];

    # ---- the five containers -----------------------------------------------
    virtualisation.oci-containers.containers = {
      zulip-database = {
        image = cfg.images.postgres;
        environment = {
          POSTGRES_DB = "zulip";
          POSTGRES_USER = "zulip";
        };
        environmentFiles = [ config.sops.templates."zulip-database.env".path ];
        volumes = [ "${cfg.dataDir}/postgresql:/var/lib/postgresql/data" ];
        extraOptions = [ "--network=zulip" "--network-alias=database" ];
      };

      zulip-memcached = {
        image = cfg.images.memcached;
        entrypoint = "/bin/sh";
        cmd = [ "-euc" memcachedCmd ];
        environment = {
          SASL_CONF_PATH = "/home/memcache/memcached.conf";
          MEMCACHED_SASL_PWDB = "/home/memcache/memcached-sasl-db";
        };
        environmentFiles = [ config.sops.templates."zulip-memcached.env".path ];
        extraOptions = [ "--network=zulip" "--network-alias=memcached" ];
      };

      zulip-rabbitmq = {
        image = cfg.images.rabbitmq;
        entrypoint = "/bin/sh";
        cmd = [ "-euc" rabbitmqCmd ];
        environment = { RABBITMQ_DEFAULT_USER = "zulip"; };
        environmentFiles = [ config.sops.templates."zulip-rabbitmq.env".path ];
        volumes = [ "${cfg.dataDir}/rabbitmq:/var/lib/rabbitmq" ];
        extraOptions = [ "--network=zulip" "--network-alias=rabbitmq" ];
      };

      zulip-redis = {
        image = cfg.images.redis;
        entrypoint = "/bin/sh";
        cmd = [ "-euc" redisCmd ];
        environmentFiles = [ config.sops.templates."zulip-redis.env".path ];
        volumes = [ "${cfg.dataDir}/redis:/data" ];
        extraOptions = [ "--network=zulip" "--network-alias=redis" ];
      };

      zulip = {
        image = cfg.images.zulip;
        environment = {
          SETTING_EXTERNAL_HOST = cfg.domain;
          SETTING_ZULIP_ADMINISTRATOR = cfg.adminEmail;
          SETTING_REMOTE_POSTGRES_HOST = "database";
          SETTING_MEMCACHED_LOCATION = "memcached:11211";
          SETTING_RABBITMQ_HOST = "rabbitmq";
          SETTING_REDIS_HOST = "redis";
          # nginx terminates TLS and forwards plain HTTP; trust its
          # X-Forwarded-{For,Proto} so client IPs and the https scheme are
          # correct. The container's own gateway is the only trusted proxy.
          TRUST_GATEWAY_IP = "True";
        }
        // optionalAttrs cfg.smtp.enable {
          SETTING_EMAIL_HOST = cfg.smtp.host;
          SETTING_EMAIL_HOST_USER = cfg.smtp.user;
          SETTING_EMAIL_PORT = toString cfg.smtp.port;
          SETTING_EMAIL_USE_TLS = "True";
          SETTING_NOREPLY_EMAIL_ADDRESS = cfg.smtp.from;
        }
        // mapAttrs' (k: v: nameValuePair "SETTING_${k}" v) cfg.extraSettings;
        environmentFiles = [ config.sops.templates."zulip-app.env".path ];
        ports = [ "127.0.0.1:${toString cfg.httpPort}:80" ];
        volumes = [
          "${cfg.dataDir}/app:/data"
          "${cfg.dataDir}/backups:/backups"
        ];
        dependsOn = [ "zulip-database" "zulip-memcached" "zulip-rabbitmq" "zulip-redis" ];
        extraOptions = [
          "--network=zulip"
          "--network-alias=zulip"
          "--ulimit=nofile=1000000:1048576"
        ];
      };
    };

    # ---- private network + unit ordering + nightly backup ------------------
    systemd.services = mkMerge [
      {
        # aardvark-dns only resolves container names/aliases on a user-defined
        # network, so create one and make every container require it.
        zulip-network = {
          description = "Create the private podman network for the Zulip stack";
          after = [ "network.target" ];
          before = map unitOf serviceNames;
          requiredBy = map unitOf serviceNames;
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = pkgs.writeShellScript "zulip-network-up" ''
              ${pkgs.podman}/bin/podman network exists zulip \
                || ${pkgs.podman}/bin/podman network create zulip
            '';
          };
        };
      }

      (mkIf cfg.backup.enable {
        # `manage.py backup` yields a point-in-time tarball (pg_dump + config)
        # that `manage.py restore` can rebuild from — the supported way to back
        # up Zulip. borg then ships dataDir/backups offsite.
        zulip-backup = {
          description = "Nightly consistent Zulip backup (manage.py backup)";
          after = [ (unitOf "zulip") ];
          requires = [ (unitOf "zulip") ];
          unitConfig.OnFailure =
            mkIf config.services.custom.alerts.enable [ "ntfy-alert@zulip-backup.service" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = pkgs.writeShellScript "zulip-backup" ''
              set -euo pipefail
              ts=$(${pkgs.coreutils}/bin/date +%Y%m%d-%H%M%S)
              ${pkgs.podman}/bin/podman exec -u zulip zulip \
                /home/zulip/deployments/current/manage.py backup \
                --output=/backups/zulip-backup-$ts.tar.gz
              # Keep the two newest tarballs locally; borg holds the longer
              # retention offsite.
              ${pkgs.coreutils}/bin/ls -1t ${cfg.dataDir}/backups/zulip-backup-*.tar.gz \
                | ${pkgs.coreutils}/bin/tail -n +3 \
                | ${pkgs.findutils}/bin/xargs -r ${pkgs.coreutils}/bin/rm -f
            '';
          };
        };
      })
    ];

    systemd.timers.zulip-backup = mkIf cfg.backup.enable {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.backup.time;
        Persistent = true;
        RandomizedDelaySec = "30m";
      };
    };

    # ---- reverse proxy (TLS terminates here) -------------------------------
    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      enableACME = true;
      serverName = cfg.domain;
      extraConfig = ''
        client_max_body_size ${cfg.clientMaxBodySize};
        # Zulip keeps long-lived event-queue (real-time) connections open.
        proxy_read_timeout 1200s;
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.httpPort}";
        proxyWebsockets = true;        # /json/events long-poll + websockets
        recommendedProxySettings = true; # Host + X-Forwarded-{For,Proto,Host}
      };
    };
  };
}
