{ config, ... }:
{
  programs.rofi = {
    enable = true;

    font = "Share Tech Mono";
    location = "center";

    terminal = config.home.sessionVariables.TERMINAL;

    theme = let 
      inherit (config.lib.formats.rasi) mkLiteral;
      inherit (config.colorscheme) colors;
    in {
      "*" = {
        width = "1000";
        font = "Share Tech Mono 14";
      };

      window = {
        height = "500px";
        border = "4px";
        border-color = mkLiteral "#${colors.base00}";
        background-color = mkLiteral "#${colors.base01}";
      };

      mainbox = {
        background-color = mkLiteral "#${colors.base01}";
      };

      inputbar = {
        background-color = mkLiteral "#${colors.base01}";
        border-radius = "5px";
        padding = "2px";
      };

      prompt = {
        background-color = mkLiteral "#${colors.base01}";
        padding = "6px";
        text-color = mkLiteral "#${colors.base0A}";
        border-radius = "3px";
        margin = "20px 0px 0px 20px";
      };

      textbox-prompt-colon = {
        expand = "false";
        str = ":";
      };

      entry = {
        padding = "6px";
        margin = "20px 0px 0px 10px";
        text-color = mkLiteral "#${colors.base0A}";
        background-color = mkLiteral "#${colors.base01}";
      };

      listview = {
        border = "0px 0px 0px";
        padding = "6px 0px 0px";
        margin = "10px 0px 0px 20px";
        columns = "3";
        lines = "5";
        background-color = mkLiteral "#${colors.base01}";
      };

      element = {
        padding = "5px";
        background-color = mkLiteral "#${colors.base01}";
        text-color = mkLiteral "#${colors.base0C}";
      };

      element-icon = {
        size = "25px";
      };

      "element selected" = {
        background-color = mkLiteral "#${colors.base0A}";
        text-color = mkLiteral "#${colors.base0E}";
      };

      mode-switcher = {
        spacing = "0";
      };

      button = {
        padding = "10px";
        background-color = mkLiteral "#${colors.base02}";
        text-color = mkLiteral "#${colors.base03}";
        vertical-align = "0.5"; 
        horizontal-align = "0.5";
      };

      "button selected" = {
        background-color = mkLiteral "#${colors.base0A}";
        text-color = mkLiteral "#${colors.base0A}";
      };

      message = {
        background-color = mkLiteral "#${colors.base02}";
        margin = "2px";
        padding = "2px";
        border-radius = "5px";
      };

      textbox = {
        padding = "6px";
        margin = "20px 0px 0px 20px";
        text-color = mkLiteral "#${colors.base0A}";
        background-color = mkLiteral "#${colors.base02}";
      };
    };
  };
}
