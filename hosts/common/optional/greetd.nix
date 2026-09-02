{
  lib,
  pkgs,
  config,
  ...
}:
let
  # programs.hyprland.enable feeds services.displayManager.sessionPackages, so
  # this directory holds hyprland.desktop. Sway is home-manager-only here and
  # deliberately absent from the menu — start it by hand from a VT if needed.
  sessions = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
in
{
  services.greetd = {
    enable = true;

    # tuigreet paints a full-screen TUI on VT1; without this systemd scribbles
    # boot messages over it.
    useTextGreeter = true;

    settings.default_session.command = lib.concatStringsSep " " [
      (lib.getExe pkgs.tuigreet)
      "--time"
      "--remember"
      "--remember-user-session"
      "--asterisks"
      "--sessions ${sessions}"
    ];
  };
}
