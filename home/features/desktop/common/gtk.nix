{ config, pkgs, ... }:
{
  gtk = {
    enable = true;
    font = {
      name = config.fontProfiles.regular.family;
      size = 12;
    };
    iconTheme = {
      name = "Adwaita Icon Theme";
      package = pkgs.gnome.adwaita-icon-theme;
    };
  };

  home.packages = with pkgs; [
    #gtk2
    gtk3 # For gtk-launch
    gtk4
  ];
}
