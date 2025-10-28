{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.custom.postgres;
in
{
  options.services.custom.postgres = {
    enable = mkEnableOption "PostgreSQL database server";

    package = mkOption {
      type = types.package;
      default = pkgs.postgresql_16;
      description = "PostgreSQL package to use";
    };

    checkConfig = mkOption {
      type = types.bool;
      default = true;
      description = "Check PostgreSQL configuration on startup";
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      checkConfig = cfg.checkConfig;
      package = cfg.package;
    };
  };
}
