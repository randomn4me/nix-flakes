#
# System Menu
#

{ config, lib, pkgs, ... }:

let
  inherit (config.lib.formats.rasi) mkLiteral;        # Theme.rasi alternative. Add Theme here
  colors = import ../themes/colors.nix;
in
{ 
  home = {
    packages = with pkgs; [
      wofi
    ];
  };

  home.file = {
    ".config/wofi/config" = {
      text = ''
        width=20%
        lines=8
        location=center
        prompt=Search...
        insensitive=true
      '';
    };
    ".config/wofi/style.css" = with colors.scheme.rose-pine; {
      text = ''
        * {
            font-size: 18px;
        }
        
        #window,
        #input {
            margin: 2px;
            border: 2px solid;
            border-radius: 8px;
            border-color: #${rose};
            background-color: #${surface};
        }
        
        #input {
            border: 0px;
            color: #${rose};
        }
        
        #entry {
            border-radius: 5px;
            color: #${muted};
        }
        
        
        #entry:selected {
            background-color: #${rose};
            color: #${base};
        }
        
        #inner-box {
            margin: 4px;
        }
      '';
    };
  };
}

