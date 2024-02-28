{ pkgs, ...}:
{
  home.packages = with pkgs; [ dunst ];

  services.dunst = let
    inherit (colors.colorscheme) colors;
  in {
    enable = true;
    width = 400;
    notification_limit = 10;
    origin = "top-right";
    font = "ShureTechMono Nerd Font Propo 10";

    urgency_low = {
      background = "#${colors.base00}";
      foreground = "#${colors.base05}";
      frame_color = "#${colors.base0C}";
    };

    urgency_normal = {
      background = "#${colors.base00}";
      foreground = "#${colors.base05}";
      frame_color = "#${colors.base0C}";
    };

    urgency_critical = {
      background = "#${colors.base00}";
      foreground = "#${colors.base05}";
      frame_color = "#${colors.base0E}";
    };
  };
}
