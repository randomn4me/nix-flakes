{
  config,
  lib,
  inputs,
  ...
}:

with lib;

let
  cfg = config.services.custom.poll;
  backupCfg = config.services.custom.backup;
in
{
  imports = [ inputs.poll-tool.nixosModules.default ];

  options.services.custom.poll = {
    enable = mkEnableOption "poll-tool, anonymous polls";

    domain = mkOption {
      type = types.str;
      default = "poll.serify.eu";
      description = "Public domain poll-tool is served on.";
    };
  };

  config = mkIf cfg.enable {
    services.poll-tool = {
      enable = true;
      baseUrl = "https://${cfg.domain}";
      passwordFile = config.sops.secrets."poll/admin-password".path;
    };

    # File content must be `ADMIN_PASSWORD=<value>` (read as an EnvironmentFile).
    sops.secrets."poll/admin-password" = { };

    # Point-in-time dump of the SQLite database on every borgmatic run
    # (services.custom.backup). dataDir is the DynamicUser symlink into
    # /var/lib/private/poll-tool; root can follow it since it owns the 0700
    # /var/lib/private.
    # borgmatic's root cannot write the service-owned directory, so it reads the
    # WAL database read-only, which only works while -wal/-shm exist. The tool
    # holds one idle connection open for its whole lifetime to keep them there;
    # a stopped poll-tool therefore fails the backup run loudly, on purpose.
    services.borgmatic = mkIf backupCfg.enable {
      settings.sqlite_databases = [
        {
          name = "poll-tool";
          path = "${config.services.poll-tool.dataDir}/poll.db";
        }
      ];
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;
      serverName = cfg.domain;

      # The tool promises anonymous answers and uvicorn runs with
      # --no-access-log, so nginx must not log IP + time + `POST /p/<code>` for
      # every submission either. The error log stays on. Covers the HTTPS server
      # only: the port-80 redirect block that forceSSL generates ignores
      # extraConfig.
      extraConfig = ''
        access_log off;
      '';

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.poll-tool.port}";
        # Host + X-Forwarded-*, needed for Secure cookies behind --proxy-headers.
        # Never add proxy_set_header Host on top: nginx then sends Host twice and
        # uvicorn (h11) rejects every request with "Invalid HTTP request received."
        recommendedProxySettings = true;
      };
    };
  };
}
