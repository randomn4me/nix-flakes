{
  programs.autorandr = {
    enable = true;
    profiles = {
      "home" = {
        config = {
          eDP1.enable = false;
          DP1.enable = true;
        };
      };
      "default" = {
        config = {
          eDP1 = {
            enable = true;
            mode = "1920x1080";
          };
        };
      };
    };
  };

  services.autorandr.enable = true;
}
