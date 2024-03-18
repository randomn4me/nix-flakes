{ pkgs, ... }:
{
  imports = [
    #./kanshi.nix # TODO understand kanshi more until I can use it
    ./foot.nix
    ./mako.nix
    ./swayidle.nix
    ./swaylock.nix
    ./waybar.nix
    ./wofi.nix
    #./bemenu.nix
  ];

  xdg.mimeApps.enable = true;
  home.packages = with pkgs; [
    xwayland
    slurp
    grim
    swaybg

    wf-recorder
    wl-clipboard
    wlr-randr
    wdisplays

    wl-mirror
    ydotool
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };
}
