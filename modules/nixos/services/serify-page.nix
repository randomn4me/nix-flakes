{ config, lib, inputs, ... }:

with lib;

let
  cfg = config.services.custom.serify-page;
in
{
  imports = [ inputs.serify-page.nixosModules.default ];

  options.services.custom.serify-page = {
    enable = mkEnableOption "Serify page service";

    domain = mkOption {
      type = types.str;
      default = "serify.eu";
      description = "Domain name for the Serify page";
    };

    redirectDomains = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of domains that should redirect to the main domain. Each domain will also have a www. variant redirected.";
      example = [ "serify.de" "serify.ai" ];
    };
  };

  config = mkIf cfg.enable {
    services.serify-page = {
      enable = true;
      domain = cfg.domain;
    };

    services.nginx.virtualHosts = builtins.listToAttrs (
      concatMap (d: [
        {
          name = d;
          value = {
            enableACME = true;
            forceSSL = true;
            globalRedirect = cfg.domain;
          };
        }
        {
          name = "www.${d}";
          value = {
            enableACME = true;
            forceSSL = true;
            globalRedirect = cfg.domain;
          };
        }
      ]) cfg.redirectDomains
    );
  };
}
