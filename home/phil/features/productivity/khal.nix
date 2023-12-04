{ pkgs, config, ... }: {
  home.packages = [ pkgs.khal ];

  xdg.configFile."khal/config".text = ''
    [calendars]

    [[peasec]]
    path = ${config.home.homeDirectory}/var/calendar/peasec/calendar
    type = calendar

    [[audacis]]
    path = ${config.home.homeDirectory}/var/calendar/audacis/personal
    type = calendar

    [locale]
    timeformat = %H:%M
    dateformat = %Y-%m-%d
    longdateformat = %Y-%m-%d
    datetimeformat = %Y-%m-%d %H:%M
    longdatetimeformat = %Y-%m-%d %H:%M

    [view]
    agenda_event_format = {calendar-color}{cancelled}{start-end-time-style} {title}{repeat-symbol}{alarm-symbol}{reset}

    [default]
    default_calendar = peasec
  '';
}
