{ config, pkgs, lib, ... }:

let
  inherit (config.colorscheme) colors;
  foot-xterm = pkgs.writeShellScriptBin "xterm" ''
    ${config.programs.foot.package}/bin/foot "$@"
  '';
in
{
  home = {
    #packages = [ foot-xterm ];
    sessionVariables.TERMINAL = "foot";
  };

  programs.foot = {
    enable = true;
    package = foot-xterm;

    server.enable = true;

    settings = {
      main = {
        term = "xterm-256color";
        font = "Inconsolata Nerd Font:size=10";
        dpi-aware = "yes";
      };

      mouse.hide-when-typing = "yes";

      colors = let
        lib = import <nixpkgs/lib>;

        mapBaseToRegularBright = colors:
        let
          generateAttrs = prefix: list: 
          lib.attrsets.genAttrs (lib.lists.forEach list (i: {
            name = "${prefix}${toString i}";
            value = colors."base${toString i}${if i < 8 then "0" else "1"}";
          }));
        in
        lib.attrsets.recursiveUpdate (generateAttrs "regular" (lib.lists.range 0 7))
        (generateAttrs "bright" (lib.lists.range 8 15));
      in mapBaseToRegularBright colors;
    };
  };
}
