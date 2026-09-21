{
  config,
  lib,
  inputs,
  ...
}:

with lib;

let
  cfg = config.services.custom.feedback;
in
{
  imports = [ inputs.feedback-tool.nixosModules.default ];

  options.services.custom.feedback = {
    enable = mkEnableOption "Workshop feedback tool";

    domain = mkOption {
      type = types.str;
      default = "feedback.serify.eu";
      description = "Public domain the feedback tool is served on.";
    };
  };

  config = mkIf cfg.enable {
    services.feedback-tool = {
      enable = true;
      baseUrl = "https://${cfg.domain}";
      passwordFile = config.sops.secrets."feedback/admin-password".path;
    };

    # File content must be `ADMIN_PASSWORD=<value>` (read as an EnvironmentFile).
    sops.secrets."feedback/admin-password" = { };

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;
      serverName = cfg.domain;

      # The tool promises anonymous feedback and uvicorn runs with
      # --no-access-log, so nginx must not log IP + time + `POST /w/<code>` for
      # every submission either. The error log stays on. Covers the HTTPS server
      # only: the port-80 redirect block that forceSSL generates ignores
      # extraConfig.
      extraConfig = ''
        access_log off;
      '';

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.feedback-tool.port}";
        # Host + X-Forwarded-*, needed for Secure cookies behind --proxy-headers.
        # Never add proxy_set_header Host on top: nginx then sends Host twice and
        # uvicorn (h11) rejects every request with "Invalid HTTP request received."
        recommendedProxySettings = true;
      };
    };
  };
}
