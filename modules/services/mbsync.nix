{ pkgs, config, ...}:
{
  systemd.user.services.mbsync = {
    Unit = { Description = "mbsync service"; };
    Service = {
      Type = "oneshot";
      ExecStart = "${config.programs.mbsync.package}/bin/mbsync -a";
    };
  };

  systemd.user.timers.mbsync = {
    Unit = { Description = "mbsync sync timer"; };
    Timer = {
      OnBootSec = "30";
      OnUnitActiveSec = "1m";
    };
    Install = { WantedBy = [ "timers.target" ]; };
  };

}
