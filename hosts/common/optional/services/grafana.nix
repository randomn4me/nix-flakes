{ config, pkgs, ... }:
let
  port = 3000;
  domain = "grafana.audacis.net";
in
{
  imports = [
    ./nginx.nix
    ./acme.nix
    ./postgres.nix
  ];

  services.nginx.virtualHosts.${domain} = {
    enableACME = true;
    forceSSL = true;
    locations."/robots.txt" = {
      extraConfig = ''
        rewrite ^/(.*)  $1;
        return 200 "User-agent: *\nDisallow: /";
      '';
    };
    locations."/" = {
      proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      database = {
        user = "grafana";
        name = "grafana";
        type = "postgres";
      };
      server = {
        http_addr = "localhost";
        http_port = port;
        domain = domain;
        serve_from_sub_path = true;
      };
    };
  };

  services.postgresql =
    let
      grafana_db_settings = config.services.grafana.settings.database;
    in
    {
      ensureDatabases = [ grafana_db_settings.name ];
      ensureUsers = [
        {
          name = grafana_db_settings.user;
          ensureDBOwnership = true;
        }
      ];
    };
}
