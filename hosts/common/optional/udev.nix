{
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2516", ATTR{idProduct}=="014b", ENV{POWERTOP_IGNORE}="1"
  '';
}
