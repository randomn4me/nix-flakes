{ config, lib, ... }:

with lib;

let
  cfg = config.services.custom.taskserver;
in
{
  options.services.custom.taskserver = {
    enable = mkEnableOption "Taskwarrior server";

    fqdn = mkOption {
      type = types.str;
      default = "audacis.net";
      description = "Fully qualified domain name for the taskserver";
    };

    listenHost = mkOption {
      type = types.str;
      default = "::";
      description = "Address to listen on (:: for IPv6)";
    };

    port = mkOption {
      type = types.port;
      default = 53589;
      description = "Port for taskserver to listen on";
    };

    organisations = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          users = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "List of users in this organisation";
          };
        };
      });
      default = {
        personal.users = [ "r4ndom" ];
      };
      description = "Organisations and their users";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Open taskserver port in firewall";
    };
  };

  config = mkIf cfg.enable {
    services.taskserver = {
      enable = true;
      fqdn = cfg.fqdn;
      listenHost = cfg.listenHost;
      organisations = cfg.organisations;
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
  };
}
