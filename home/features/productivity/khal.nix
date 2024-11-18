{ pkgs, config, ... }:
{
  home.packages = [ pkgs.khal ];

  xdg.configFile."khal/config".text = ''
    [calendars]

    [[peasec]]
    path = ${config.home.homeDirectory}/var/calendar/peasec/calendar
    type = calendar

    [[audacis-philipp]]
    path = ${config.home.homeDirectory}/var/calendar/audacis/personal
    type = calendar

    [[audacis-camilla]]
    path = ${config.home.homeDirectory}/var/calendar/audacis/personal_shared_by_camillakuehn
    type = calendar

    [[audacis-kids]]
    path = ${config.home.homeDirectory}/var/calendar/audacis/imported-kidsics-1_shared_by_camillakuehn
    type = calendar

    [[audacis-ferien]]
    path = ${config.home.homeDirectory}/var/calendar/audacis/ferien-3
    type = calendar

    [[audacis-birthdays]]
    path = ${config.home.homeDirectory}/var/calendar/audacis/contact_birthdays
    type = calendar

    [locale]
    timeformat = %H:%M
    dateformat = %Y-%m-%d
    longdateformat = %Y-%m-%d
    datetimeformat = %Y-%m-%d %H:%M
    longdatetimeformat = %Y-%m-%d %H:%M

    [default]
    default_calendar = peasec
  '';
}
