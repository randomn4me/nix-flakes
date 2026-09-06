{ config, lib, ... }:
with lib;
let
  cfg = config.services.custom.audio;
in
{
  options.services.custom.audio.enable = mkEnableOption "Enable pipewire with alsa und pulseaudio support";

  config = mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;

      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
