{ config, pkgs, ... }:
{
  gtk = {
    enable = true;
    font = {
      name = config.fontProfiles.regular.family;
      size = 12;
    };
    iconTheme = {
      name = "Nordzy Icons";
      package = pkgs.nordzy-icon-theme;
    };
    cursorTheme = {
      name = "Nordzy Cursor";
      package = pkgs.nordzy-cursor-theme;
    };
  };

  home.packages = with pkgs; [
    #gtk2
    gtk3 # For gtk-launch
    gtk4
  ];
}
