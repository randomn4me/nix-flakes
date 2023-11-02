{ config, ... }:

let home = config.home.homeDirectory;
in {
  programs = {
    taskwarrior = {
      enable = true;

      dataLocation = "${home}/var/task";
      colorTheme = "solarized-dark-256";

      config = {
        weekstart = "Monday";

        default.due = "2h";

        report = {
          maybe = {
            columns = [ "id" "project" "tags" "description" ];
            labels = [ "ID" "Project" "Tags" "Description" ];
            filter = "status:pending and +maybe";
          };

          next.filter = "status:pending and -maybe";
        };

        search.case.sensitive = "no";

        urgency = {
          uda.priority = {
            H.coefficient = 6.0;
            M.coefficient = 3.0;
            L.coefficient = -1.0;
          };

          project.coefficient = 0;
          tags.coefficient = 0;
          scheduled.coefficient = 0;
          age.coefficient = 0;

          user.tag = {
            mail.coefficient = 2;
            call.coefficient = 2;
            unikita.coefficient = -0.5;
          };
        };

        taskd = {
          certificate = "${home}/usr/docs/misc/task/r4ndom/public.cert";
          key = "${home}/usr/docs/misc/task/r4ndom/private.key";
          ca = "${home}/usr/docs/misc/task/r4ndom/ca.cert";
          server = "audacis.net:53589";
          credentials = "personal/r4ndom/3bc693fb-9fcf-4e20-858d-3785afed332a";
        };
      };
    };
  };

  services.taskwarrior-sync = { enable = true; };
}
