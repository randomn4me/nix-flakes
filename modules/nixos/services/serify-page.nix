{ config, lib, inputs, ... }:

with lib;

let
  cfg = config.services.custom.serify-page;
in
{
  imports = [ inputs.serify-page.nixosModules.default ];

  options.services.custom.serify-page = {
    enable = mkEnableOption "Serify page service";

    domain = mkOption {
      type = types.str;
      default = "serify.eu";
      description = "Domain name for the Serify page";
    };
  };

  config = mkIf cfg.enable {
    services.serify-page = {
      enable = true;
      domain = cfg.domain;
    };
  };
}
