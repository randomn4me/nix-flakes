{
  services.kanshi = {
    enable = true;

    profiles = {
      primary = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 1.5;
          }
        ];
      };

      secondary = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "Lenovo Group Limited P27h-30 V30A4CH5";
            #mode = "2540x1440@@59.951Hz";
            status = "enable";
            scale = 1.0;
          }
        ];
      };
    };

    # TODO add if to check whether hyprland is enabled
    systemdTarget = "hyprland-session.target";
  };
}
