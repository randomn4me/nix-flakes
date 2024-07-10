{ pkgs, ... }:
{
  gtk = {
    enable = true;
    iconTheme = {
      name = "Adwaita Icon Theme";
      package = pkgs.adwaita-icon-theme;
    };
  };

  home.packages = with pkgs; [
    gtk3
    gtk4
  ];
}
