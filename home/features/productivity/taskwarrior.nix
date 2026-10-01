{
  config,
  lib,
  pkgs,
  ...
}:

let
  home = config.home.homeDirectory;
  task = "${config.programs.taskwarrior.package}/bin/task";
  syncFile = "${config.xdg.configHome}/task/sync.rc";
in
{
  programs = {
    taskwarrior = {
      enable = true;
      package = pkgs.taskwarrior3;

      dataLocation = "${home}/var/task";
      colorTheme = "solarized-dark-256";

      config = {
        weekstart = "Monday";

        report = {
          maybe = {
            columns = [
              "id"
              "project"
              "tags"
              "description"
            ];
            labels = [
              "ID"
              "Project"
              "Tags"
              "Description"
            ];
            filter = "status:pending and +maybe";
          };

          next.filter = "status:pending and -maybe";
        };

        search.case.sensitive = "no";

        # TaskChampion sync server on netcup (services.custom.taskchampion).
        sync.server.url = "https://task.audacis.net";

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
          annotations.coefficient = 0;

          user.tag = {
            mail.coefficient = 1;
            call.coefficient = 1;
            dl.coefficient = 0;
            unikita.coefficient = -0.5;
            waiting.coefficient = -2;
          };
        };
      };

      # sync.server.client_id and sync.encryption_secret: both act as
      # credentials and this repo is public, so they live in netcup's sops
      # (taskchampion/client) and are copied to each replica once:
      #   sops -d --extract '["taskchampion"]["client"]' hosts/netcup/secrets.yaml > ~/.config/task/sync.rc
      extraConfig = ''
        include ${syncFile}
      '';
    };

  };

  home.shellAliases = {
    "done-today" = "${task} completed end:today";
  };

  services.taskwarrior-sync = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    package = config.programs.taskwarrior.package;
  };

  # home-manager's taskwarrior-sync is systemd-only; same 5-minute sync on macOS.
  launchd.agents.taskwarrior-sync = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    config = {
      ProgramArguments = [
        task
        "synchronize"
      ];
      StartInterval = 300;
      ProcessType = "Background";
    };
  };
}
