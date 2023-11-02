{
  services.xserver = {
    enable = true;
    windowManager.cwm.enable = true;

    displayManager.defaultSession = "none+cwm";
    displayManager.lightdm = {
      enable = true;
      greeters.slick.enable = true;
    };

    libinput.enable = true;

    layout = "us";
    xkbOptions = "ctrl:nocaps";
  };
}
