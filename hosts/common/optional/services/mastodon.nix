{ config, ... }:
{
  imports = [ ./postgres.nix ];

  services.mastodon = {
    enable = true;
    localDomain = "social.audacis.net";
    configureNginx = true;
    smtp.fromAddress = "noreply@social.audacis.net";
    extraConfig.SINGLE_USER_MODE = "true";
    streamingProcesses = 1;

    mediaAutoRemove = {
      enable = true;
      olderThanDays = 14;
    };
  };

  services.postgresql =
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
    };
}
