{ config, ... }:
let
  colors = config.colorscheme.palette;
in
{
  # Same wallpaper, blur and palette as the rest of the desktop.
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      background = [
        {
          path = "${config.wallpaper}";
          blur_passes = 3;
          blur_size = 4;
        }
      ];

      input-field = [
        {
          size = "300, 50";
          position = "0, 0";
          halign = "center";
          valign = "center";

          outline_thickness = 3;
          rounding = 40;

          outer_color = "rgb(${colors.base05})";
          inner_color = "rgb(${colors.base01})";
          font_color = "rgb(${colors.base05})";
          check_color = "rgb(${colors.base04})";
          fail_color = "rgb(B1252E)";

          font_family = "Share Tech Mono";
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";

          # The de/us toggle makes the active layout worth showing on the
          # lock screen.
          dots_center = true;
        }
      ];

      label = [
        {
          text = "$LAYOUT";
          color = "rgb(${colors.base05})";
          font_family = "Share Tech Mono";
          font_size = 14;
          position = "0, -80";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
