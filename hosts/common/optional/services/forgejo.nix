{ config, ... }:
{
  imports = [ ./postgres.nix ];

  services.forgejo = {
    enable = true;
    database.type = "postgres";

    lfs.enable = true;

    settings = {
      server = {
        DOMAIN = "git.audacis.net";
        ROOT_URL = "https://${config.services.forgejo.settings.server.DOMAIN}";
        HTTP_PORT = 3000;
      };

      service.DISABLE_REGISTRATION = true;

      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };
    };
  };

  services.nginx = {
    virtualHosts.${config.services.forgejo.settings.server.DOMAIN} = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        client_max_body_size 512M;
      '';
      locations."/".proxyPass = "http://localhost:${toString config.services.forgejo.settings.server.HTTP_PORT}";
    };
  };
}
