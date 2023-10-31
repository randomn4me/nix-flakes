{
  imports = [
    ./hetzner-mail.nix

    #./audacis-contacts.nix

    #./audacis-calendar.nix
  ];

  programs.msmtp.enable = true;
  programs.mbsync.enable = true;

  services.mbsync = {
    enable = true;
    frequency = "*-*-* *:*:00/30";
  };
}
