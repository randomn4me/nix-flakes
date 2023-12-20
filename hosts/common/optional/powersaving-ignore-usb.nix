{pkgs, ...}: let
  # source https://askubuntu.com/a/1026527
  undoPowertopTuningScript = pkgs.writeShellScript "undo-powertop-tuning" ''
    #!/bin/sh

      TARGET_DEVICE_NAME="SK622 Mechanical Keyboard - White Edition"
      HIDDEVICES=$(ls /sys/bus/usb/drivers/usbhid | grep -oE '^[0-9]+-[0-9\.]+' | sort -u)

      for i in $HIDDEVICES; do
    DEVICE_NAME=$(cat /sys/bus/usb/devices/$i/product)
      if [ "$DEVICE_NAME" = "$TARGET_DEVICE_NAME" ]; then
      echo "Enabling $DEVICE_NAME"
      echo 'on' > /sys/bus/usb/devices/$i/power/control
      fi
      done
  '';
in {
  systemd.services.undo-powertop-tuning = {
    description = "Undo certain Powertop auto-tunings";
    after = ["powertop.service"];
    requires = ["powertop.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = undoPowertopTuningScript;
      RemainAfterExit = true;
    };
  };
}
