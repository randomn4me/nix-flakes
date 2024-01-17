{ config, lib, ... }:
{
    home.sessionVariables.TERMINAL = lib.mkForce "foot";

    programs.foot = {
        enable = true;

        settings = {
            main = {
                font = "Inconsolata Nerd Font:Regular:size=11";
                font-bold = "Inconsolata Nerd Font:Bold:size=11";
                font-italic = "Inconsolata Nerd Font:Regular:size=11";

                term = "xterm-direct";
            };

            mouse.hide-when-typing = true;

            colors = let
                inherit (config.colorscheme) colors;
            in {
                background = "${colors.base00}";
                foreground = "${colors.base05}";

                selection-foreground = "${colors.base00}";
                selection-background = "${colors.base05}";

                regular0 = "${colors.base02}";
                regular1 = "${colors.base08}";
                regular2 = "${colors.base0B}";
                regular3 = "${colors.base09}";
                regular4 = "${colors.base0C}";
                regular5 = "${colors.base0D}";
                regular6 = "${colors.base0A}";
                regular7 = "${colors.base05}";

                bright0 = "${colors.base02}";
                bright1 = "${colors.base08}";
                bright2 = "${colors.base0B}";
                bright3 = "${colors.base09}";
                bright4 = "${colors.base0C}";
                bright5 = "${colors.base0D}";
                bright6 = "${colors.base0A}";
                bright7 = "${colors.base05}";
            };

        };
    };

}
