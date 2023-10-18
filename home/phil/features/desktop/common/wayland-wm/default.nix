{ pkgs, ... }:
{
  imports = [
    ./alacritty.nix
    ./kanshi.nix
    ./mako.nix
    ./swayidle.nix
    ./swaylock.nix
    ./waybar.nix
    ./wofi.nix
    ./zathura.nix
  ];

  xdg.mimeApps.enable = true;
  home.packages = with pkgs; [
    grim
    gtk3 # For gtk-launch
    flatpak
    xwayland
    slurp
    wf-recorder
    wl-clipboard

    wl-mirror
    ydotool
    libreoffice
    feh
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };
}
