{ pkgs, config, ... }:
let
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  hyprlock = "${config.programs.hyprlock.package}/bin/hyprlock";
  grep = "${pkgs.gnugrep}/bin/grep";
  systemctl = "${pkgs.systemd}/bin/systemctl";

  lockTime = 3 * 60;
  suspendTime = 15 * 60;

  # Any power supply reporting online means we're on mains or USB-C PD. Matching
  # the lid policy in hosts/peasec (suspend on battery, stay up when plugged in),
  # so an idle machine on AC keeps serving ssh.
  onBattery = "! ${grep} -q 1 /sys/class/power_supply/*/online";
in
{
  # Same schedule as ../sway/swayidle.nix: lock, then mute the mic, then blank.
  # hypridle fires listeners on absolute idle time, so the staggered timeouts
  # are written out rather than derived from an "after lock" offset.
  services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "${pkgs.procps}/bin/pgrep -x hyprlock || ${hyprlock}";
        before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
        # Under the Lua config `hyprctl dispatch` takes a Lua expression;
        # the bare `dispatch dpms on` form is legacy-parser only.
        after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
      };

      listener = [
        {
          timeout = lockTime;
          on-timeout = "${pkgs.systemd}/bin/loginctl lock-session";
        }
        {
          timeout = lockTime + 10;
          on-timeout = "${wpctl} set-mute @DEFAULT_SOURCE@ 1";
          on-resume = "${wpctl} set-mute @DEFAULT_SOURCE@ 0";
        }
        {
          timeout = lockTime + 180;
          on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"off\" })'";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
        }
        {
          # general.before_sleep_cmd locks the session first, so this cannot
          # suspend to an unlocked desktop.
          timeout = suspendTime;
          on-timeout = "${onBattery} && ${systemctl} suspend";
        }
      ];
    };
  };
}
