{ lib, ... }:
{
  programs.msmtp.enable = true;
  programs.mbsync.enable = true;

  services.mbsync = {
    enable = true;
    frequency = lib.mkDefault "*-*-* *:00/5";
  };
}
