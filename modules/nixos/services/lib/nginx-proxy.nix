{ lib, ... }:

with lib;

{
  # Helper function to create a standard nginx reverse proxy virtual host
  mkNginxProxy = {
    domain,
    proxyPass,
    enableACME ? true,
    forceSSL ? true,
    disallowRobots ? true,
    proxyWebsockets ? false,
    recommendedProxySettings ? false,
    extraConfig ? "",
    extraLocations ? {},
  }: {
    ${domain} = mkMerge [
      {
        inherit enableACME forceSSL;
        serverName = domain;

        locations."/" = {
          inherit proxyPass;
          ${if proxyWebsockets then "proxyWebsockets = true;" else ""}
          ${if recommendedProxySettings then "recommendedProxySettings = true;" else ""}
        };
      }
      (mkIf disallowRobots {
        locations."/robots.txt".extraConfig = ''
          rewrite ^/(.*)  $1;
          return 200 "User-agent: *\nDisallow: /";
        '';
      })
      (mkIf (extraConfig != "") {
        inherit extraConfig;
      })
      {
        locations = extraLocations;
      }
    ];
  };
}
