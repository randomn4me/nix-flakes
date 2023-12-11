{ lib, ... }:
{
  imports = [
    #./peasec-mail.nix
    ./peasec-calendar.nix
  ];

  programs.msmtp.enable = true;
  programs.mbsync.enable = true;

  #programs.khard.enable = true;
  #programs.khal.enable = true;

  services.mbsync = {
    enable = true;
    frequency = lib.mkDefault "*-*-* *:00/30";
  };

  programs.vdirsyncer.enable = true;

  services.vdirsyncer = {
    enable = true;
    frequency = lib.mkDefault "*-*-* *:00/5";
  };
}
