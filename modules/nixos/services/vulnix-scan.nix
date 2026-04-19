{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.custom.vulnix-scan;
  alertsCfg = config.services.custom.alerts;
  ntfyCfg = config.services.custom.ntfy;

  ntfySend = pkgs.writeShellScript "ntfy-send-vulnix" ''
    TOPIC="$1"
    TITLE="$2"
    MESSAGE="$3"
    PRIORITY="''${4:-default}"
    TAGS="''${5:-}"

    TOKEN=$(cat ${alertsCfg.ntfyTokenFile})

    ${pkgs.curl}/bin/curl -sSf \
      -H "Authorization: Bearer $TOKEN" \
      -H "Title: $TITLE" \
      -H "Priority: $PRIORITY" \
      -H "Tags: $TAGS" \
      -d "$MESSAGE" \
      "http://${ntfyCfg.listenAddress}/$TOPIC"
  '';
in
{
  options.services.custom.vulnix-scan = {
    enable = mkEnableOption "vulnix vulnerability scan after rebuild";

    calendar = mkOption {
      type = types.str;
      default = "daily";
      description = "Systemd calendar expression for scan schedule";
    };

    topic = mkOption {
      type = types.str;
      default = alertsCfg.topic;
      description = "ntfy topic for vulnix reports";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.vulnix ];

    systemd.services.vulnix-scan = {
      description = "Scan current system for known vulnerabilities with vulnix";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
      };

      script = ''
        OUTPUT=$(${pkgs.vulnix}/bin/vulnix --system 2>&1) || true
        COUNT=$(echo "$OUTPUT" | ${pkgs.gnugrep}/bin/grep -c "^[^ ]" || true)

        if [ "$COUNT" -gt 0 ]; then
          SUMMARY=$(echo "$OUTPUT" | ${pkgs.coreutils}/bin/head -c 3500)
          ${ntfySend} ${cfg.topic} "Vulnix: $COUNT vulnerable packages" "$SUMMARY" "high" "warning"
        else
          ${ntfySend} ${cfg.topic} "Vulnix: no vulnerabilities found" "${config.networking.hostName}: system scan clean" "default" "white_check_mark"
        fi
      '';
    };

    systemd.timers.vulnix-scan = {
      description = "Run vulnix vulnerability scan on schedule and after boot";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.calendar;
        OnBootSec = "5min";
        Persistent = true;
      };
    };
  };
}
