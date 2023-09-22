{ config, ... }:

let
  home = config.home.homeDirectory;
in
{ 
  programs = {
    taskwarrior = {
      enable = true;

      dataLocation = "${home}/var/task";
      colorTheme = "solarized-dark-256";

      config = {
        weekstart = "Monday";

        default.due = "2h";

        report.maybe.filter = "status:pending and +maybe";
        search.case.sensitive = "no";

        taskd = {
          # TODO: replace ${home} with home-manager config information
          certificate = "${home}/usr/docs/misc/task/r4ndom/public.cert";
          key = "${home}/usr/docs/misc/task/r4ndom/private.key";
          ca = "${home}/usr/docs/misc/task/r4ndom/ca.cert";
          server = "audacis.net:53589";
          credentials = "personal/r4ndom/3bc693fb-9fcf-4e20-858d-3785afed332a";
        };
      };
    };
  };

  services.taskwarrior-sync = {
    enable = true;
  };
}
