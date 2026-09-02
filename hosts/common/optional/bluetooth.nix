{
  hardware.bluetooth = {
    enable = true;
    # The radio idles at a few hundred milliwatts even with nothing paired.
    # blueman (or `bluetoothctl power on`) brings it up when it is wanted.
    powerOnBoot = false;
    settings.General.Experimental = true;
  };
  services.blueman.enable = true;
}
