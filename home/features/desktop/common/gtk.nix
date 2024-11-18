{ pkgs, ... }:
{
  gtk = {
    enable = true;

    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };

    iconTheme = {
      name = "Adwaita Icon Theme";
      package = pkgs.adwaita-icon-theme;
    };

    font = {
      name = "Sans";
      size = 10;
    };
  };

  home.packages = with pkgs; [
    gtk3
    gtk4
  ];
}
