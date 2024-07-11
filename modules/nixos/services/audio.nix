{ config, lib, ... }:
with lib;
let
  cfg = config.audio.pipewire;
in
{
  options.audio.pipewire.enable = mkEnableOption "Enable pipewire with alsa und pulseaudio support";

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
