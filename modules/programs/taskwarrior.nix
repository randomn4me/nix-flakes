{ config, lib, pkgs, ... }:

{ 
  programs = {
    taskwarrior = {
      enable = true;
      config = {
        weekstart = "Monday";

        default.due = "2h";

        report.maybe.filter = "status:pending and -maybe";
        search.case.sensitive = "no";

        taskd = {
          certificate = "$HOME/usr/docs/misc/task/r4ndom/public.cert";
          key = "$HOME/usr/docs/misc/task/r4ndom/private.key";
          ca = "$HOME/usr/docs/misc/task/r4ndom/ca.cert";
          server = "audacis.net:53589";
          credentials = "personal/r4ndom/3bc693fb-9fcf-4e20-858d-3785afed332a";
        };
      };
      dataLocation = "$HOME/var/task";

      colorTheme = "solarized-dark-256";

    };
  };
}
