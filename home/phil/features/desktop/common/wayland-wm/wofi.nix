{ config, ... }:
let
  inherit (config.colorscheme) colors;
in
{
programs.wofi = {
    enable = true;

    settings = {
      width = "20%";
      lines = 8;
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
            border-color: #${colors.base0A};
            background-color: #${colors.base02};
        }
        
        #input {
            border: 0px;
            color: #${colors.base0A};
        }
        
        #entry {
            border-radius: 5px;
            color: #${colors.base05};
        }
        
        
        #entry:selected {
            background-color: #${colors.base0A};
            color: #${colors.base02};
        }
        
        #inner-box {
            margin: 4px;
        }
    '';
  };
}
