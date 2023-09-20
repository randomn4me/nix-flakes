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
      primary = true;
    }
  ];
}
