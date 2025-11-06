{ config, lib, ... }:

with lib;

let
  cfg = config.services.custom.freshrss;
in
{
  options.services.custom.freshrss = {
    enable = mkEnableOption "FreshRSS RSS aggregator";

    virtualHost = mkOption {
      type = types.str;
      default = "freshrss.audacis.net";
      description = "Virtual host name for FreshRSS";
    };

    baseUrl = mkOption {
      type = types.str;
      default = "https://freshrss.audacis.net";
      description = "Base URL for FreshRSS";
    };

    defaultUser = mkOption {
      type = types.str;
      default = "admin";
      description = "Default admin username for FreshRSS (login username)";
    };

    passwordFile = mkOption {
      type = types.str;
      default = "/run/secrets/freshrss/passphrase";
      description = "Path to file containing admin password (must exist before service starts)";
    };

    authType = mkOption {
      type = types.str;
      default = "form";
      description = "Authentication type (form, http_auth, etc.)";
    };

    language = mkOption {
      type = types.str;
      default = "en";
      description = "Default language for FreshRSS interface";
    };

    nginx = {
      enableACME = mkOption {
        type = types.bool;
        default = true;
        description = "Enable ACME SSL certificates";
      };

      forceSSL = mkOption {
        type = types.bool;
        default = true;
        description = "Force SSL for all connections";
      };
    };
  };

  config = mkIf cfg.enable {
    services.freshrss = {
      enable = true;
      virtualHost = cfg.virtualHost;
      baseUrl = cfg.baseUrl;
      defaultUser = cfg.defaultUser;
      passwordFile = cfg.passwordFile;
      authType = cfg.authType;
      language = cfg.language;
    };

    services.nginx.virtualHosts.${cfg.virtualHost} = {
      enableACME = cfg.nginx.enableACME;
      forceSSL = cfg.nginx.forceSSL;
    };
  };
}
