{ pkgs, ... }:
{
  imports = [
    ./alacritty.nix
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
    imv
    mimeo
    xwayland
    #pulseaudio
    slurp
    #waypipe
    wf-recorder
    wl-clipboard
    wl-mirror
    ydotool
    libreoffice
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };
}
