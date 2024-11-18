{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cfg = config.custom.camera-webcam;
in
{
  options.custom.camera-webcam.enable = mkEnableOption "Enable to use camera as webcam.";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ffmpeg
      gphoto2
      mpv
    ];

    boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback.out ];
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=1 exclusive_caps=1 max-buffers=2 card_label="webcam"
    '';
  };
}
