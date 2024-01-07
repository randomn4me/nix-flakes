{ pkgs, lib, config, ... }:

let
  swaylock = "${config.programs.swaylock.package}/bin/swaylock";
  pgrep = "${pkgs.procps}/bin/pgrep";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
  swaymsg = "${config.wayland.windowManager.sway.package}/bin/swaymsg";
  #chayang = "${pkgs.chayang}/bin/chayang";

  isLocked = "${pgrep} -x ${swaylock}";
  lockTime = 5 * 60;
  #dimStartTime = builtins.floor 6.5 * 60; # 3.5 * 60
  #dimTime = builtins.floor 0.6 * 60; # 0.5 * 60

  # Makes two timeouts: one for when the screen is not locked (lockTime+timeout) and one for when it is.
  afterLockTimeout = { timeout, command, resumeCommand ? null }: [
    { timeout = lockTime + timeout; inherit command resumeCommand; }
    { command = "${isLocked} && ${command}"; inherit resumeCommand timeout; }
  ];
in
{
  services.swayidle = {
    enable = true;
    systemdTarget = "graphical-session.target";
    timeouts =
      # Lock screen
      [{
        timeout = lockTime;
        command = "${swaylock} -k --daemonize";
      }] ++
      # Mute mic
      (afterLockTimeout {
        timeout = 10;
        command = "${pactl} set-source-mute @DEFAULT_SOURCE@ yes";
        resumeCommand = "${pactl} set-source-mute @DEFAULT_SOURCE@ no";
      }) ++
      # Turn off displays (hyprland)
      (lib.optionals config.wayland.windowManager.hyprland.enable
        (afterLockTimeout {
          timeout = 60;
          command = "${hyprctl} dispatch dpms off";
          resumeCommand = "${hyprctl} dispatch dpms on";
        })) ++
      # Turn off displays (sway)
      (lib.optionals config.wayland.windowManager.sway.enable
        (afterLockTimeout {
          timeout = 60;
          command = "${swaymsg} 'output * dpms off'";
          resumeCommand = "${swaymsg} 'output * dpms on'";
      }));
  };
}
