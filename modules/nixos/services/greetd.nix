{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.custom.greetd;

  # programs.hyprland.enable feeds services.displayManager.sessionPackages, so
  # this directory holds hyprland.desktop.
  sessions = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
in
{
  options.custom.greetd = {
    enable = mkEnableOption "Enable greetd with a tuigreet greeter";

    package = mkPackageOption pkgs "tuigreet" { };

    extraArgs = mkOption {
      description = ''
        Extra arguments for the greeter, appended after the defaults
        (`--time --remember --remember-user-session --asterisks --sessions`).
      '';
      type = types.listOf types.str;
      example = [ "--greeting 'welcome'" ];
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;

      # tuigreet paints a full-screen TUI on VT1; without this systemd scribbles
      # boot messages over it.
      useTextGreeter = true;

      settings.default_session.command = concatStringsSep " " (
        [
          (getExe cfg.package)
          "--time"
          "--remember"
          "--remember-user-session"
          "--asterisks"
          "--sessions ${sessions}"
        ]
        ++ cfg.extraArgs
      );
    };
  };
}
