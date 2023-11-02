let
  common-config = {
    width = "150px";
    height = "20px";
  };
in {
  services.polybar = {
    enable = true;

    config = {
      "bar/top-right" = { modules-center = [ "date" ]; } // common-config;

      "bar/top-left" = {
        modules-center = [ "battery" "pulseaudio" ];
      } // common-config;

      "module/battery" = {
        type = "internal/battery";
        full-at = 99;
        low-at = 10;
        battery = "BAT0";
        adapter = "ADP1";
      };

      "module/date" = {
        type = "internal/date";
        internal = 5;
        date = "%d.%m";
        time = "%H:%M";
        label = "%date% %time%";
      };

      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        use-ui-max = false;
        interval = 1;
      };
    };

    script = "polybar top-right top-left &";
  };
}
