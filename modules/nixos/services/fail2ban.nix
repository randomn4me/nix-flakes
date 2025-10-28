{ config, lib, ... }:

with lib;

let
  cfg = config.services.custom.fail2ban;
in
{
  options.services.custom.fail2ban = {
    enable = mkEnableOption "fail2ban intrusion prevention";

    maxretry = mkOption {
      type = types.int;
      default = 5;
      description = "Number of violations before banning an IP";
    };

    bantime = mkOption {
      type = types.str;
      default = "24h";
      description = "Duration of ban";
    };

    ignoreIP = mkOption {
      type = types.listOf types.str;
      default = [ "130.83.0.0/16" ];
      description = "IP addresses or networks to never ban";
    };

    bantimeIncrement = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable progressive ban time increments";
      };

      formula = mkOption {
        type = types.str;
        default = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
        description = "Formula for calculating progressive ban times";
      };

      maxtime = mkOption {
        type = types.str;
        default = "168h";
        description = "Maximum ban time";
      };

      overalljails = mkOption {
        type = types.bool;
        default = true;
        description = "Apply ban time increment across all jails";
      };
    };

    jails = mkOption {
      type = types.attrsOf types.str;
      default = {
        apache-nohome-iptables = ''
          # Block an IP address if it accesses a non-existent
          # home directory more than 5 times in 10 minutes,
          # since that indicates that it's scanning.
          filter = apache-nohome
          action = iptables-multiport[name=HTTP, port="http,https"]
          logpath = /var/log/httpd/error_log*
          backend = auto
          findtime = 600
          bantime  = 600
          maxretry = 5
        '';
      };
      description = "fail2ban jail configurations";
    };
  };

  config = mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
      maxretry = cfg.maxretry;
      bantime = cfg.bantime;
      ignoreIP = cfg.ignoreIP;
      bantime-increment = {
        enable = cfg.bantimeIncrement.enable;
        formula = cfg.bantimeIncrement.formula;
        maxtime = cfg.bantimeIncrement.maxtime;
        overalljails = cfg.bantimeIncrement.overalljails;
      };
      jails = cfg.jails;
    };
  };
}
