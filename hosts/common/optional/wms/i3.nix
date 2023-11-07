{
  services.xserver = {
    enable = true;

    desktopManager.xterm.enable = false;
    windowManager.i3.enable = true;

    displayManager.defaultSession = "none+i3";
    displayManager.lightdm.enable = true;

    libinput.enable = true;

    layout = "de";
    xkbOptions = "ctrl:nocaps";
  };
}

