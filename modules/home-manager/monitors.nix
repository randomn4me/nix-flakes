{ lib, config, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.monitors;
in {
  options.monitors = mkOption {
    type = types.listOf (types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          example = "DP-1";
        };
        primary = mkOption {
          type = types.bool;
          default = false;
        };
        width = mkOption {
          type = types.int;
          example = 1920;
        };
        height = mkOption {
          type = types.int;
          example = 1080;
        };
        refreshRate = mkOption {
          type = types.int;
          default = 60;
        };
        x = mkOption {
          type = types.int;
          default = 0;
        };
        scaling = mkOption {
            type = types.float;
            default = 1;
            example = "1.333333";
        };
        y = mkOption {
          type = types.int;
          default = 0;
        };
        enabled = mkOption {
          type = types.bool;
          default = true;
        };
        workspaces = mkOption {
          type = types.nullOr (types.listOf types.int);
          default = null;
        };
      };
    });
    default = [ ];
  };
  config = {
    assertions = [{
      assertion = ((lib.length config.monitors) != 0)
        -> ((lib.length (lib.filter (m: m.primary) config.monitors)) == 1);
      message = "Exactly one monitor must be set to primary.";
    }];
  };
}
