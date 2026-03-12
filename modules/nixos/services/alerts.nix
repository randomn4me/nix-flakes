{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.custom.alerts;
  ntfyCfg = config.services.custom.ntfy;

  ntfySend = pkgs.writeShellScript "ntfy-send" ''
    TOPIC="$1"
    TITLE="$2"
    MESSAGE="$3"
    PRIORITY="''${4:-default}"
    TAGS="''${5:-}"

    TOKEN=$(cat ${cfg.ntfyTokenFile})

    ${pkgs.curl}/bin/curl -sf \
      -H "Authorization: Bearer $TOKEN" \
      -H "Title: $TITLE" \
      -H "Priority: $PRIORITY" \
      -H "Tags: $TAGS" \
      -d "$MESSAGE" \
      "http://${ntfyCfg.listenAddress}/$TOPIC"
  '';
in
{
  options.services.custom.alerts = {
    enable = mkEnableOption "ntfy-based system alerts";

    ntfyTokenFile = mkOption {
      type = types.path;
      description = "Path to file containing the ntfy access token";
    };

    topic = mkOption {
      type = types.str;
      default = "alerts-${config.networking.hostName}";
      description = "Default ntfy topic for alerts";
    };

    fail2ban.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Send alerts on fail2ban ban events";
    };

    systemdServices = mkOption {
      type = types.listOf types.str;
      default = [ "forgejo" "vaultwarden" "postgresql" "nginx" "ntfy-sh" ];
      description = "Systemd services to monitor for failure";
    };

    diskSpace = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable disk space monitoring";
      };

      threshold = mkOption {
        type = types.int;
        default = 90;
        description = "Disk usage percentage threshold for alerts";
      };

      interval = mkOption {
        type = types.str;
        default = "hourly";
        description = "How often to check disk space";
      };
    };

    acme.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Send alerts on ACME certificate renewal failures";
    };

    forgejoBackup.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Send alerts on Forgejo backup failures";
    };

    nixGc.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Send alerts on Nix garbage collection failures";
    };
  };

  config = mkIf cfg.enable {
    systemd.services = let
      # OnFailure overrides for monitored services
      serviceOverrides = builtins.listToAttrs (map (svc: {
        name = svc;
        value = {
          unitConfig.OnFailure = [ "ntfy-alert@${svc}.service" ];
        };
      }) cfg.systemdServices);

      # ACME certificate renewal failure alerts
      acmeOverrides = let
        acmeDomains = builtins.attrNames (filterAttrs (_: vhost: vhost.enableACME or false) config.services.nginx.virtualHosts);
      in mkIf cfg.acme.enable (builtins.listToAttrs (map (domain: {
        name = "acme-${domain}";
        value = {
          unitConfig.OnFailure = [ "ntfy-alert@acme-${domain}.service" ];
        };
      }) acmeDomains));

      # Forgejo backup failure alert
      forgejoOverride = mkIf (cfg.forgejoBackup.enable && config.services.forgejo.dump.enable or false) {
        forgejo-dump.unitConfig.OnFailure = [ "ntfy-alert@forgejo-dump.service" ];
      };

      # Nix GC failure alert
      nixGcOverride = mkIf cfg.nixGc.enable {
        nix-gc.unitConfig.OnFailure = [ "ntfy-alert@nix-gc.service" ];
      };

    in mkMerge [
      # Template service for systemd failure notifications
      {
        "ntfy-alert@" = {
          description = "Send ntfy alert for %i failure";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${ntfySend} ${cfg.topic} 'Service Failed: %i' '${config.networking.hostName}: unit %i has failed' urgent rotating_light";
          };
        };
      }

      serviceOverrides
      acmeOverrides
      forgejoOverride
      nixGcOverride

      # Disk space monitoring
      (mkIf cfg.diskSpace.enable {
        disk-space-alert = {
          description = "Check disk space and alert if above threshold";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = pkgs.writeShellScript "check-disk-space" ''
              USAGE=$(${pkgs.coreutils}/bin/df / --output=pcent | ${pkgs.coreutils}/bin/tail -1 | ${pkgs.coreutils}/bin/tr -d ' %')
              if [ "$USAGE" -ge ${toString cfg.diskSpace.threshold} ]; then
                ${ntfySend} ${cfg.topic} "Disk Space Warning" "${config.networking.hostName}: disk usage at ''${USAGE}%" high warning
              fi
            '';
          };
        };
      })
    ];

    systemd.timers.disk-space-alert = mkIf cfg.diskSpace.enable {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.diskSpace.interval;
        Persistent = true;
      };
    };

    # Fail2ban ntfy action
    environment.etc."fail2ban/action.d/ntfy.local".text = mkIf cfg.fail2ban.enable ''
      [Definition]
      actionban = ${ntfySend} ${cfg.topic} "Fail2ban: <name>" "${config.networking.hostName}: banned <ip> in jail <name> (<failures> failures)" default lock
      actionunban =
    '';

    services.fail2ban.jails = mkIf cfg.fail2ban.enable {
      DEFAULT.settings = {
        action = "%(action_)s\n           ntfy";
      };
    };
  };
}
