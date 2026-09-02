{
  pkgs,
  config,
  lib,
  ...
}:

let
  swaylock = "${config.programs.swaylock.package}/bin/swaylock";
  pgrep = "${pkgs.procps}/bin/pgrep";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  swaymsg = "${config.wayland.windowManager.sway.package}/bin/swaymsg";
  #chayang = "${pkgs.chayang}/bin/chayang";

  isLocked = "${pgrep} -x ${swaylock}";
  lockTime = 3 * 60;

  # Makes two timeouts: one for when the screen is not locked (lockTime+timeout) and one for when it is.
  afterLockTimeout =
    {
      timeout,
      command,
      resumeCommand ? null,
    }:
    [
      {
        timeout = lockTime + timeout;
        inherit command resumeCommand;
      }
      {
        command = "${isLocked} && ${command}";
        inherit resumeCommand timeout;
      }
    ];
in
{
  services.swayidle = {
    enable = true;
    systemdTarget = "graphical-session.target";
    timeouts =
      # Lock screen
      [
        {
          timeout = lockTime;
          command = "${swaylock} -i ${config.wallpaper} --daemonize --grace 30";
        }
      ]
      ++
        # Mute mic
        (afterLockTimeout {
          timeout = 10;
          command = "${wpctl} set-mute @DEFAULT_SOURCE@ 1";
          resumeCommand = "${wpctl} set-mute @DEFAULT_SOURCE@ 0";
        })
      ++
        # Turn off displays (sway)
        (lib.optionals config.wayland.windowManager.sway.enable (afterLockTimeout {
          timeout = 180;
          command = "${swaymsg} 'output * dpms off'";
          resumeCommand = "${swaymsg} 'output * dpms on'";
        }));
  };
}
