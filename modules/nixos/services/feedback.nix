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

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.feedback-tool.port}";
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
