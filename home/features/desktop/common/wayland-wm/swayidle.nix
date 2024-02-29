{ pkgs, config, ... }:

let
  swaylock = "${config.programs.swaylock.package}/bin/swaylock";
  pgrep = "${pkgs.procps}/bin/pgrep";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
  #chayang = "${pkgs.chayang}/bin/chayang";

  isLocked = "${pgrep} -x ${swaylock}";
  lockTime = 5 * 60;

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
        command = "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ 1";
        resumeCommand = "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ 0";
      });
      #++
      ## Turn off displays
      #(lib.optionals config.wayland.windowManager.hyprland.enable
      #  (afterLockTimeout {
      #    timeout = 60;
      #    command = "${hyprctl} dispatch dpms off";
      #    resumeCommand = "${hyprctl} dispatch dpms on";
      #}));
  };
}
