{ config, pkgs, ... }:
let
  port = 3333;
  domain = "md.audacis.net";
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
      proxyPass = "http://localhost:${builtins.toString port}";
      proxyWebsockets = true;
      extraConfig = "proxy_ssl_server_name on;";
    };
  };

  environment.systemPackages = with pkgs; [ hedgedoc ];

  services.hedgedoc = {
    enable = true;
    settings = {
      allowEmailRegistration = false;
      db = {
        username = "hedgedoc";
        database = "hedgedoc";
        host = "/run/postgresql";
        dialect = "postgresql";
      };
      domain = domain;
      port = port;
      useSSL = false;
      protocolUseSSL = true;
    };
  };

  services.postgresql =
    let
      hedgedoc_db_settings = config.services.hedgedoc.settings.db;
    in
    {
      ensureDatabases = [ hedgedoc_db_settings.database ];
      ensureUsers = [
        {
          name = hedgedoc_db_settings.username;
          ensureDBOwnership = true;
        }
      ];
    };
}
