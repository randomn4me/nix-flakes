{ config, lib, ... }:

with lib;

let
  cfg = config.services.custom.mastodon;
in
{
  options.services.custom.mastodon = {
    enable = mkEnableOption "Mastodon social network server";

    localDomain = mkOption {
      type = types.str;
      default = "social.audacis.net";
      description = "Domain name for Mastodon instance";
    };

    configureNginx = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically configure nginx reverse proxy";
    };

    smtp = {
      fromAddress = mkOption {
        type = types.str;
        default = "noreply@social.audacis.net";
        description = "Email address for outgoing emails";
      };
    };

    singleUserMode = mkOption {
      type = types.bool;
      default = true;
      description = "Run Mastodon in single user mode";
    };

    streamingProcesses = mkOption {
      type = types.int;
      default = 1;
      description = "Number of streaming processes";
    };

    mediaAutoRemove = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Automatically remove old media";
      };

      olderThanDays = mkOption {
        type = types.int;
        default = 14;
        description = "Remove media older than this many days";
      };
    };

    setupPostgres = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically setup PostgreSQL database and user";
    };
  };

  config = mkIf cfg.enable {
    services.mastodon = {
      enable = true;
      localDomain = cfg.localDomain;
      configureNginx = cfg.configureNginx;
      smtp.fromAddress = cfg.smtp.fromAddress;
      extraConfig.SINGLE_USER_MODE = toString cfg.singleUserMode;
      streamingProcesses = cfg.streamingProcesses;

      mediaAutoRemove = {
        enable = cfg.mediaAutoRemove.enable;
        olderThanDays = cfg.mediaAutoRemove.olderThanDays;
      };
    };

    services.postgresql = mkIf cfg.setupPostgres (
      let
        mastodon_db_settings = config.services.mastodon.database;
      in
      {
        ensureDatabases = [ mastodon_db_settings.name ];
        ensureUsers = [
          {
            name = mastodon_db_settings.user;
            ensureDBOwnership = true;
          }
        ];
      }
    );
  };
}
