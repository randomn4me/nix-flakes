{
  imports = [
    ./nginx.nix
    ./acme.nix
  ];

  services.vaultwarden = {
    enable = true;
    config = {
      SIGNUPS_ALLOWED = false;
    };
  };

  services.nginx.virtualHosts."vault.audacis.net" = {
    enableACME = true;
    forceSSL = true;
    locations."/robots.txt" = {
      extraConfig = ''
        rewrite ^/(.*)  $1;
        return 200 "User-agent: *\nDisallow: /";
      '';
    };
    locations."/" = { proxyPass = "http://127.0.0.1:8000"; };
  };
}

