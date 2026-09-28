{
  config,
  lib,
  inputs,
  ...
}:

with lib;

let
  cfg = config.services.custom.crm;
  backupCfg = config.services.custom.backup;
  ntfyCfg = config.services.custom.ntfy;
  tokenFile = "/var/lib/ntfy-sh/serify-crm-token";
in
{
  imports = [ inputs.serify-crm.nixosModules.default ];

  options.services.custom.crm = {
    enable = mkEnableOption "serify-crm, contacts and deals for the founders";

    domain = mkOption {
      type = types.str;
      default = "crm.serify.eu";
      description = "Public domain the CRM is served on.";
    };

    userTopics = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Forgejo username to personal ntfy topic for the daily reminder.";
    };
  };

  config = mkIf cfg.enable {
    services.serify-crm = {
      enable = true;
      baseUrl = "https://${cfg.domain}";
      # File content: OAUTH_CLIENT_ID=<id> and OAUTH_CLIENT_SECRET=<secret>
      # of the OAuth2 application in Forgejo (redirect URI
      # https://<domain>/auth/callback).
      environmentFile = config.sops.secrets."crm/env".path;
      ntfy = mkIf ntfyCfg.enable {
        url = "http://${ntfyCfg.listenAddress}";
        tokenFile = tokenFile;
        userTopics = cfg.userTopics;
      };
    };

    sops.secrets."crm/env" = { };
    sops.secrets."ntfy/serify-crm" = mkIf ntfyCfg.enable { };

    # A publish-only ntfy user. The ntfy module rebuilds its auth database on
    # every start, which invalidates the token; PartOf restarts the CRM with
    # the provisioning unit so it picks up the new one.
    services.custom.ntfy.auth.users = mkIf ntfyCfg.enable [
      {
        username = "serify-crm";
        passwordFile = config.sops.secrets."ntfy/serify-crm".path;
        inherit tokenFile;
        access = [
          {
            topic = "serify-crm*";
            permission = "write-only";
          }
        ];
      }
    ];
    systemd.services.serify-crm = mkIf ntfyCfg.enable {
      after = [ "ntfy-sh-provision-users.service" ];
      wants = [ "ntfy-sh-provision-users.service" ];
      partOf = [ "ntfy-sh-provision-users.service" ];
    };

    # Same pattern as poll.nix: the service keeps one connection open, so the
    # -wal/-shm files exist and borgmatic can read the database read-only.
    services.borgmatic = mkIf backupCfg.enable {
      settings.sqlite_databases = [
        {
          name = "serify-crm";
          path = "${config.services.serify-crm.dataDir}/crm.db";
        }
      ];
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = true;
      forceSSL = true;
      serverName = cfg.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.serify-crm.port}";
        recommendedProxySettings = true;
      };
      # contact-relay files leads over loopback; from outside the endpoint
      # has no business being reachable.
      locations."= /api/v1/leads".return = "404";
    };
  };
}
