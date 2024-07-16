{ config, lib, ... }:
with lib;
let
  cfg = config.audio;
in
{
  options.audio.enable = mkEnableOption "Enable pipewire with alsa und pulseaudio support";

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
