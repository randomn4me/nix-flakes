{
  lib,
  config,
  osConfig,
  ...
}:

with lib;

let
  cfg = config.custom.gc;
in
{
  options.custom.gc.enable = mkOption {
    description = "Enable home-manager-gc based on nixos gc";
    type = types.bool;
    default = true;
  };

  config = mkIf cfg.enable {
    nix.gc = {
      automatic = osConfig.nix.gc.automatic;
      frequency = osConfig.nix.gc.dates;
      options = osConfig.nix.gc.options;
    };
  };

}
