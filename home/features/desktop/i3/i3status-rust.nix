{ pkgs, config, ... }:
{
  programs.i3status-rust =
    let
      head = "${pkgs.coreutils}/bin/head";
      jq = "${pkgs.jq}/bin/jq";
      khal = "${pkgs.khal}/bin/khal";
      playerctl = "${config.services.playerctld.package}/bin/playerctl";

      jsonOutput =
        name:
        {
          pre ? "",
          icon ? "",
          state ? "",
          text ? "required",
          short_text ? "",
        }:
        "${pkgs.writeShellScriptBin "i3status-rust-${name}" ''
          set -euo pipefail
          ${pre}
          ${jq} -cn \
          --arg icon "${icon}" \
          --arg state "${state}" \
          --arg text "${text}" \
          --arg short_text "${short_text}" \
          '{icon:$icon,state:$state,text:$text,short_text:$short_text}'
        ''}/bin/i3status-rust-${name}";
    in
    {
      enable = true;

      bars = {
        default = {
          icons = "awesome6";
          theme = "space-villain";

          blocks = [
            {
              block = "custom";
              interval = 1;
              command = jsonOutput "music" {
                pre = # sh
                  ''
                    status="$(${playerctl} status)"

                    if [ $status != "Stopped" ]; then
                      text="$(${playerctl} metadata --format '{{artist}} - {{title}}')";
                      short_text="$(${playerctl} metadata --format '{{artist}} - {{title}} ({{album}})')";
                    else
                      text=""
                      short_text=""
                    fi
                  '';
                icon = "music";
                state = "Info";
                text = "$text";
                short_text = "$short_text";
              };
              json = true;
              hide_when_empty = true;
            }

            {
              block = "taskwarrior";
              interval = 30;
              data_location = config.programs.taskwarrior.dataLocation;
              warning_threshold = 5;
              critical_threshold = 10;
              filters = [
                {
                  name = "today";
                  filter = "+PENDING +OVERDUE or +DUETODAY";
                }
              ];
            }

            {
              block = "maildir";
              interval = 2;
              inboxes = [ "${config.accounts.email.maildirBasePath}/*/*" ];
              threshold_warning = 1;
              threshold_critical = 10;
              display_type = "new";
            }

            {
              block = "custom";
              interval = 60;
              command = jsonOutput "appointments" {
                pre = ''
                  filter='-a peasec -a audacis-philipp'

                  text=$(${khal} list $filter now 1d --format "{start-time}" --day-format "" --notstarted | ${head} -n 1)
                  short_text=$(${khal} list $filter now 1d --format "{start-time} {title}" --day-format "" --notstarted | ${head} -n 1)
                '';
                icon = "calendar";
                state = "Good";
                text = "$text";
                short_text = "$short_text";
              };
              json = true;
              hide_when_empty = true;
            }

            {
              block = "sound";
              max_vol = 100;
              click = [
                {
                  button = "left";
                  cmd =
                    let
                      pavu = "${pkgs.pavucontrol}/bin/pavucontrol";
                    in
                    "${pavu}";
                }
              ];
            }

            {
              block = "battery";
              device = "BAT0";
              interval = 30;
              full_format = " $icon $percentage ";
            }

            {
              block = "time";
              interval = 10;
              format = " $timestamp.datetime(f:'%d.%m %R') ";
            }
          ];
        };
      };
    };
}
