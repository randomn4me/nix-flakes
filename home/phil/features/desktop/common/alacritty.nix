{ config, pkgs, ... }:

let
  inherit (config.colorscheme) colors;
  alacritty-xterm = pkgs.writeShellScriptBin "xterm" ''
    ${config.programs.alacritty.package}/bin/alacritty "$@"
  '';
in {
  home = {
    packages = [ alacritty-xterm ];
    sessionVariables.TERMINAL = "alacritty";
  };

  programs.alacritty = {
    enable = true;
    settings = {
      env = { TERM = "xterm-direct"; };

      font = {
        normal = {
          family =
            "Inconsolata Nerd Font"; # TODO: Enable fontProfiles to make it globally available
          style = "Regular";
        };
        italic = {
          family =
            "Inconsolata Nerd Font"; # TODO: Enable fontProfiles to make it globally available
          style = "Regular";
        };
        bold = {
          family =
            "Inconsolata Nerd Font"; # TODO: Enable fontProfiles to make it globally available
          style = "Bold";
        };
      };

      colors = {
        primary = {
          background = "0x${colors.base00}";
          foreground = "0x${colors.base05}";
        };

        cursor = {
          text = "0x${colors.base05}";
          cursor = "0x${colors.base07}";
        };

        vi_mode_cursor = {
          text = "0x${colors.base05}";
          cursor = "0x${colors.base07}";
        };

        line_indicator = {
          foreground = "None";
          background = "None";
        };

        selection = {
          text = "0x${colors.base05}";
          background = "0x${colors.base07}";
        };

        normal = {
          black = "0x${colors.base02}";
          red = "0x${colors.base08}";
          green = "0x${colors.base0B}";
          yellow = "0x${colors.base09}";
          blue = "0x${colors.base0C}";
          magenta = "0x${colors.base0D}";
          cyan = "0x${colors.base0A}";
          white = "0x${colors.base05}";
        };

        bright = {
          black = "0x${colors.base03}";
          red = "0x${colors.base08}";
          green = "0x${colors.base0B}";
          yellow = "0x${colors.base09}";
          blue = "0x${colors.base0C}";
          magenta = "0x${colors.base0D}";
          cyan = "0x${colors.base0A}";
          white = "0x${colors.base06}";
        };

        hints = {
          start = {
            foreground = "#${colors.base04}";
            background = "#${colors.base01}";
          };
          end = {
            foreground = "#${colors.base03}";
            background = "#${colors.base01}";
          };
        };
      };

    };
  };
}
