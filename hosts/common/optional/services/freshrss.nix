{ config, ... }:
{
  services.freshrss = {
    enable = true;
    virtualHost = "freshrss.audacis.net";
    baseUrl = "https://freshrss.audacis.net";
    passwordFile = "/run/secrets/freshrss";
  };

  services.nginx.virtualHosts."freshrss.audacis.net" = {
    enableACME = true;
    forceSSL = true;
  };
}
