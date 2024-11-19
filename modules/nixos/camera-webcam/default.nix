{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cfg = config.custom.camera-webcam;
  serviceName = "start-webcam-stream";
  start-webcam-stream = pkgs.writeShellScriptBin "${serviceName}" ''
    ${pkgs.gphoto2}/bin/gphoto2 --stdout --capture-movie
  '';
in
{
  # TODO: finish this module
  options.custom.camera-webcam.enable = mkEnableOption "Enable to use camera as webcam.";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ffmpeg
      gphoto2
      mpv
    ];

    boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    boot.kernelModules = [ "v4l2loopback" ];
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="Camera webcam" exclusive_caps=1
    '';

    systemd.services.${serviceName} = {
      description = "Start camera webcam stream";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = start-webcam-stream;
        RemainAfterExit = true;
      };
    };

    services.udev = {
      enable = true;

      extraRules = ''
        ACTION=="add",\
        SUBSYSTEM=="usb",\
        ATTRS{idVendor}=="2516",\
        ATTRS{idProduct}=="014b",\
        TAG+="systemd",\
        ENV{SYSTEMD_WANTS}+="${serviceName}.service"

        ACTION=="add",\
        SUBSYSTEM=="usb",\
        ATTRS{idVendor}=="093a",\
        ATTRS{idProduct}=="2510",\
        TAG+="systemd",\
        ENV{SYSTEMD_WANTS}+="${serviceName}.service"
      '';
    };
  };
}
