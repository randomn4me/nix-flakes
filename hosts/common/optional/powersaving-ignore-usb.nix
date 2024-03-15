{pkgs, ...}: let
  # source https://askubuntu.com/a/1026527
  # with adjustments
  ignoreUSBInputDevicesScript = devices: pkgs.writeShellScript "powersaving-ignore-usb" ''
    #!/usr/bin/env sh

    TARGET_DEVICE_NAMES=(${builtins.concatStringsSep " " devices})
    HIDDEVICES=$(ls /sys/bus/usb/drivers/usbhid | grep -oE '^[0-9]+-[0-9\.]+' | sort -u)

    for i in $HIDDEVICES; do
      DEVICE_NAME=$(cat /sys/bus/usb/devices/$i/product)
      for ((j = 0; j < ''${#TARGET_DEVICE_NAMES[@]}; j++)); do
        if [[ "$DEVICE_NAME" == "''${TARGET_DEVICE_NAMES[$j]}" ]]; then
          echo "Enabling $DEVICE_NAME"
          echo 'on' > /sys/bus/usb/devices/$i/power/control
        fi
      done
    done
  '';

  serviceName = "ignoreUSBInputDevices";
in {
  systemd.services.${serviceName} = {
    description = "Ignore USB input devices for powertop autotune";
    after = ["powertop.service"];
    requires = ["powertop.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ignoreUSBInputDevicesScript [
        "SK622 Mechanical Keyboard - White Edition"
        "Optical Mouse"
      ];
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
}
