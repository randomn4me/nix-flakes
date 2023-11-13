{ pkgs, config, ... }: {
  home.packages = [ pkgs.khal ];

  xdg.configFile."khal/khal.conf".text = ''
    [calendars]

    [[audacis]]
    path=${config.home.homeDirectory}/var/calendar/peasec/calendar
  '';
}
