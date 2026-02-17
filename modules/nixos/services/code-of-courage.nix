{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg = config.services.custom.code-of-courage;
  domain = "code-of-courage.de";
in
{
  imports = [ inputs.code-of-courage.nixosModules.default ];

  options.services.custom.code-of-courage = {
    enable = mkEnableOption "Code of Courage - Interactive comic for security education";
  };

  config = mkIf cfg.enable {
    # Explicitly allow unfree for this package
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "code-of-courage"
    ];

    services.code-of-courage.enable = true;

    # Override the nginx virtualHost to use ACME instead of manual SSL certificates
    services.nginx.virtualHosts.${domain} = {
      enableACME = mkForce true;
      forceSSL = mkForce true;
      # Remove manual SSL certificate configuration
      sslCertificate = mkForce null;
      sslCertificateKey = mkForce null;
    };
  };
}
