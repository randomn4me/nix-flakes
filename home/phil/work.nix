{ inputs, outputs, ... }:
{
  imports = [
    ./global
    #./features/desktop/wireless
    ./features/desktop/hyprland
    #./features/pass
  ];

  monitors = [
    {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      workspace = "3";
      x = 0;
      primary = true;
    }
  ];
}
