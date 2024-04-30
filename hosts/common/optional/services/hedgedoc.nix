{config, ...}:
let
  port = 3333;
  domain = "md.audacis.net";
in {
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
      proxyPass = "http://localhost:${port}";
      proxyWebsockets = true;
      extraConfig = "proxy_ssl_server_name on;";
    };
  };

  services.hedgedoc = {
    enable = true;
    settings = {
      db = {
        username = "hedgedoc";
        database = "hedgedoc";
        host = "localhost:5432";
        dialect = "postgresql";
      };
      domain = domain;
      port = port;
      useSSL = false;
      protocolUseSSL = true;
    };
  };

  services.postgresql = let
    hgdc = config.services.hedgedoc;
  in {
    ensureDatabases = [ hgdc.settings.db.database ];
    ensureUsers = [
      {
        name = hgdc.settings.db.username;
        ensurePermissions."DATABASE ${hgdc.settings.db.database}" = "ALL PRIVILEGES";
      }
    ];
  };
}
