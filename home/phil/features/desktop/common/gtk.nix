{ config, pkgs, ... }:

#let
#  inherit (inputs.nix-colors.lib-contrib { inherit pkgs; }) gtkThemeFromScheme;
#in rec 
{
  gtk = {
    enable = true;
    font = {
      name = config.fontProfiles.regular.family;
      size = 12;
    };
    #theme = {
    #  name = "${config.colorscheme.slug}";
    #  package = gtkThemeFromScheme { scheme = config.colorscheme; };
    #};
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
  };

  #services.xsettingsd = {
  #  enable = true;
  #  settings = {
  #    "Net/ThemeName" = "${gtk.theme.name}";
  #    "Net/IconThemeName" = "${gtk.iconTheme.name}";
  #  };
  #};

  home.packages = with pkgs; [
    #gtk2
    gtk3 # For gtk-launch
    gtk4
  ];
}
