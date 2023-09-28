{ config, pkgs, inputs, ... }:

#let
#  inherit (inputs.nix-colors.lib-contrib { inherit pkgs; }) gtkThemeFromScheme;
#in rec 
{
  gtk = {
    enable = true;
    #font = {
    #  name = config.fontProfiles.regular.family;
    #  size = 12;
    #};
    # TODO
    #theme = {
    #  name = "${config.colorscheme.rose-pine}";
    #  package = gtkThemeFromScheme { scheme = config.colorscheme; };
    #};
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };

  services.xsettingsd = {
    enable = true;
    #settings = {
    #  "Net/ThemeName" = "${gtk.theme.name}";
    #  "Net/IconThemeName" = "${gtk.iconTheme.name}";
    #};
  };
}