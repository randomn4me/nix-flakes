{ lib, ... }:
{
  services.vdirsyncer = {
    enable = true;
    frequency = lib.mkDefault "*-*-* *:00/30";
  };
  programs.vdirsyncer.enable = true;
}
