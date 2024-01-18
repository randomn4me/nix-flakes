{pkgs, ...}: let
  # source https://askubuntu.com/a/1026527
  ignoreKeyboardScript = pkgs.writeShellScript "powersaving-ignore-usb" ''
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

  serviceName = "ignoreKeyboard";
in {
  systemd.services.${serviceName} = {
    description = "Ignore keyboard for powertop autotune";
    after = ["powertop.service"];
    requires = ["powertop.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ignoreKeyboardScript;
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
    '';
  };
}
