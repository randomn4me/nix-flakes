{ config, ... }:
let
  inherit (config.colorscheme) colors;
in
{
  home.sessionVariables.RUNNER = "wofi --show dmenu";

  programs.wofi = {
    enable = true;

    settings = {
      width = "400px";
      lines = 8;
      matching = "fuzzy";
      insensitive = true;
      location = "center";
      prompt = "Search..";
    };

    style = ''
      * {
          font: Share Tech Mono;
          font-size: 18px;
      }

      #window,
      #input {
          margin: 2px;
          border: 2px solid;
          border-radius: 8px;
          border-color: #FFFFFF;
          background-color: #000000;
      }

      #input {
          border: 0px;
          color: #FFFFFF;
      }

      #entry {
          border-radius: 5px;
          color: #FFFFFF;
      }


      #entry:selected {
          background-color: #${colors.base0F};
          color: #${colors.base01};
      }

      #inner-box {
          margin: 4px;
      }
    '';
  };
}
