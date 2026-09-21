{ config, lib, ... }:

with lib;

let
  cfg = config.services.custom.umami;
in
{
  options.services.custom.umami = {
    enable = mkEnableOption "Umami analytics";

    domain = mkOption {
      type = types.str;
      default = "stats.serify.eu";
      description = "Public domain the dashboard and tracker script are served on.";
    };

    port = mkOption {
      type = types.port;
      # Upstream default 3000 collides with Forgejo's default HTTP_PORT.
      default = 3010;
      description = "Internal port Umami listens on (behind nginx).";
    };
  };

  config = mkIf cfg.enable {
    services.umami = {
      enable = true;
      # Local database + role `umami`, reached over the unix socket (peer auth).
      createPostgresqlDatabase = true;
      settings = {
        APP_SECRET_FILE = config.sops.secrets."umami/app-secret".path;
        PORT = cfg.port;
        DISABLE_TELEMETRY = true;
      };
    };

    # Plain random string (e.g. `openssl rand -hex 32`); signs login sessions.
    sops.secrets."umami/app-secret" = { };

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;
      serverName = cfg.domain;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        # Host + X-Forwarded-For: Umami derives the visitor's location from the
        # client IP. Never add proxy_set_header Host on top: nginx then sends
        # Host twice and the upstream rejects the request with a 400.
        recommendedProxySettings = true;
      };
    };
  };
}
