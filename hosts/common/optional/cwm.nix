{
  services.xserver = {
    enable = true;
    windowManager.cwm.enable = true;

    libinput.enable = true;

    layout = "us";
    xkbOptions = "ctrl:nocaps";
  };
}
