{ lib, ... }:
{
  imports = [
    ./hetzner-mail.nix

    ./audacis-contacts.nix
    ./audacis-calendar.nix
  ];

  programs.msmtp.enable = true;
  programs.mbsync.enable = true;

  services.mbsync = {
    enable = true;
    frequency = lib.mkDefault "*-*-* *:00/30";
  };

  programs.vdirsyncer.enable = true;
  services.vdirsyncer = {
    enable = true;
    frequency = lib.mkDefault "*-*-* *:00/30";
  };
}
