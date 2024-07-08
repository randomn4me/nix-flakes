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
    #gtk2
    gtk3 # For gtk-launch
    gtk4
  ];
}
