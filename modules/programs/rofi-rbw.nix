#
# Password Menu
#

{ config, lib, pkgs, ... }:

let
  inherit (config.lib.formats.rasi) mkLiteral;
  colors = import ../themes/colors.nix;
in
{ 
  home = {
    packages = with pkgs; [
      rofi-rbw
    ];
  };

  home.file = {
    ".config/rofi-rbw.rc" = {
      text = ''
        selector = wofi
	clipboarder = wl-copy
	clear-after = 60
      '';
    };
  };
}


