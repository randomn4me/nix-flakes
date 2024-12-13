{ inputs, ... }:
{
  environment.defaultPackages = [ inputs.audacis-blog.x86_64-linux.website ];
  services.nginx.virtualHosts."/" = {
    forceSSL = true;
    enableACME = true;
    root = inputs.audacis-blog.x86_64-linux.website;
  };
}
