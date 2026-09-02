{ pkgs, ... }:
{
  gtk = {
    enable = true;

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
