{ config, pkgs, lib, ... }:
{
    home.sessionVariables.TERMINAL = lib.mkForce "foot";
    programs.foot = {
        enable = true;
        server = true;
    };

    settings = {
        main = {
            font = "Inconsolata Nerd Font";
            dpi-aware = true;
        };

        mouse.hide-when-typing = true;

    };

}
