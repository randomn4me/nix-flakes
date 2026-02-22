{ config, ... }:
let
  colors = config.colorscheme.palette;
in
{
  home.sessionVariables.RUNNER = "wofi --show dmenu";

  programs.wofi = {
    enable = true;

    settings = {
      width = "400px";
      lines = 8;
      matching = "contains";
      insensitive = true;
      location = "top_right";
      prompt = "Search..";
      sort_order = "alphabetical";
    };

    style = ''
      * {
          font: Share Tech Mono;
          font-size: 14px;
      }

      #window,
      #input {
          margin: 2px;
          border: 2px solid;
          border-radius: 8px;
          border-color: #B1252E;
          background-color: #010101;
      }

      #input {
          border: 0px;
          color: #${colors.base05};
      }

      #entry {
          border-radius: 5px;
          color: #${colors.base05};
      }


      #entry:selected {
          color: #B1252E;
          background-color: #010101;
      }

      #inner-box {
          margin: 4px;
      }
    '';
  };
}
