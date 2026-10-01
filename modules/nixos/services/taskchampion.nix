{ config, lib, ... }:

with lib;

let
  cfg = config.services.custom.taskchampion;
  upstream = config.services.taskchampion-sync-server;
in
{
  options.services.custom.taskchampion = {
    enable = mkEnableOption "TaskChampion sync server for Taskwarrior 3";

    domain = mkOption {
      type = types.str;
      default = "task.audacis.net";
      description = "Domain name the sync server is reachable at";
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        File containing `CLIENT_ID=<uuid>`, the only client allowed to sync.
        The client ID acts as an access token (anyone holding it can push
        versions), so it is passed via environmentFile rather than the
        upstream allowClientIds, which would put it in the Nix store. Null
        allows any client.
      '';
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
    # Task data is end-to-end encrypted by the clients; the server only stores
    # opaque version blobs in SQLite under /var/lib/taskchampion-sync-server.
    services.taskchampion-sync-server = {
      enable = true;
      host = "127.0.0.1";
    };

    systemd.services.taskchampion-sync-server.serviceConfig.EnvironmentFile = mkIf (
      cfg.environmentFile != null
    ) cfg.environmentFile;

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = cfg.nginx.enableACME;
      forceSSL = cfg.nginx.forceSSL;
      serverName = cfg.domain;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString upstream.port}";
        # Snapshots of a large task list exceed nginx's 1M default.
        extraConfig = ''
          client_max_body_size 100M;
        '';
      };
    };
  };
}
