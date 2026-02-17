{ config, lib, inputs, ... }:

with lib;

let
  cfg = config.services.custom.audacis-blog;
in
{
  imports = [ inputs.audacis-blog.nixosModules.default ];

  options.services.custom.audacis-blog = {
    enable = mkEnableOption "Audacis blog service";

    domain = mkOption {
      type = types.str;
      default = "audacis.net";
      description = "Domain name for the blog";
    };
  };

  config = mkIf cfg.enable {
    # The actual audacis-blog module should be imported via the flake input
    # in the host configuration. This module just provides a convenient
    # wrapper to configure it.
    services.audacis-blog = {
      enable = true;
      domain = cfg.domain;
    };
  };
}
