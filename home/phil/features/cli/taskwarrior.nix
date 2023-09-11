{ config, lib, pkgs, ... }:

{ 
  programs = {
    taskwarrior = {
      enable = true;

      dataLocation = "$HOME/var/task";
      colorTheme = "solarized-dark-256";

      config = {
        weekstart = "Monday";

        default.due = "2h";

        report.maybe.filter = "status:pending and +maybe";
        search.case.sensitive = "no";

        taskd = {
          # TODO: replace $HOME with home-manager config information
          certificate = "$HOME/usr/docs/misc/task/philipp.cert.pem";
          key = "$HOME/usr/docs/misc/task/philipp.key.pem";
          ca = "$HOME/usr/docs/misc/task/ca.cert.pem";
          server = "audacis.net:53589";
          credentials = "audacis/philipp/645f4519-332b-4c67-9cda-46ae34fa9494";
        };
      };
    };
  };
}
