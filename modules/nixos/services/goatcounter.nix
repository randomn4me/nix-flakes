{ config, lib, ... }:

with lib;

let
  cfg = config.services.custom.goatcounter;
in
{
  options.services.custom.goatcounter = {
    enable = mkEnableOption "GoatCounter analytics";

    domain = mkOption {
      type = types.str;
      default = "stats.serify.eu";
      description = "Public domain the dashboard and /count endpoint are served on.";
    };

    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Internal address GoatCounter listens on (behind nginx).";
    };

    port = mkOption {
      type = types.port;
      default = 8081;
      description = "Internal port GoatCounter listens on.";
    };

    dbFile = mkOption {
      type = types.str;
      default = "/var/lib/goatcounter/goatcounter.sqlite3";
      description = ''
        SQLite database path. Pinned explicitly (rather than relying on the
        upstream default relative to WorkingDirectory) so that the running
        service and the one-off `goatcounter db create site` bootstrap command
        operate on the exact same file. Lives under the service's StateDirectory
        (/var/lib/goatcounter), which systemd owns for the DynamicUser.
      '';
    };

    nginx = {
      enableACME = mkOption {
        type = types.bool;
        default = true;
        description = "Obtain a Let's Encrypt certificate for the domain.";
      };

      forceSSL = mkOption {
        type = types.bool;
        default = true;
        description = "Redirect HTTP to HTTPS.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.goatcounter = {
      enable = true;
      inherit (cfg) address port;
      # nginx terminates TLS; -tls=proxy makes GoatCounter trust
      # X-Forwarded-* and serve plain HTTP on the loopback listener.
      proxy = true;
      extraArgs = [
        # Apply pending schema migrations on start. Without this the service
        # would fail (Restart=always loop) the first time a GoatCounter version
        # bump ships a new migration; with it, `serve` self-heals on deploy.
        "-automigrate"
        "-db"
        "sqlite+${cfg.dbFile}"
      ];
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = cfg.nginx.enableACME;
      forceSSL = cfg.nginx.forceSSL;
      serverName = cfg.domain;

      locations."/" = {
        proxyPass = "http://${cfg.address}:${toString cfg.port}";
        # No recommendedProxySettings on this host, so forward the client IP
        # explicitly — GoatCounter derives country stats from X-Forwarded-For.
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };
}
