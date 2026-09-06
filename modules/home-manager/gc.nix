{
  lib,
  config,
  osConfig ? null,
  ...
}:

with lib;

let
  cfg = config.custom.gc;
in
{
  options.custom.gc.enable = mkOption {
    description = ''
      Mirror the host's nix.gc schedule for the user's own generations.

      Only meaningful when home-manager runs as a NixOS module: a standalone
      configuration has no `osConfig` to follow, so this is a no-op there
      rather than an evaluation error.
    '';
    type = types.bool;
    default = true;
  };

  config = mkIf (cfg.enable && osConfig != null) {
    nix.gc = {
      automatic = osConfig.nix.gc.automatic;
      options = osConfig.nix.gc.options;
    };
  };
}
