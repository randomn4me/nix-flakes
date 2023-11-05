{ config, pkgs, inputs, ... }:

let
  # Dependencies
  date = "${pkgs.coreutils}/bin/date";
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";

  alacritty = "${config.programs.alacritty.package}/bin/alacritty";
  ncmpcpp = "${config.programs.ncmpcpp.package}/bin/ncmpcpp";
  neomutt = "${config.programs.neomutt.package}/bin/neomutt";

  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";

  wc = "${pkgs.coreutils}/bin/wc";
  printf = "${pkgs.coreutils}/bin/printf";
  pgrep = "${pkgs.procps}/bin/pgrep";

  jq = "${pkgs.jq}/bin/jq";
  find = "${pkgs.findutils}/bin/find";

  # Function to simplify making waybar outputs
  jsonOutput = name:
    { pre ? "", text ? "", tooltip ? "", alt ? "", class ? "", percentage ? ""
    }:
    "${
      pkgs.writeShellScriptBin "waybar-${name}" ''
        set -euo pipefail
        ${pre}
        ${jq} -cn \
        --arg text "${text}" \
        --arg tooltip "${tooltip}" \
        --arg alt "${alt}" \
        --arg class "${class}" \
        --arg percentage "${percentage}" \
        '{text:$text,tooltip:$tooltip,alt:$alt,class:$class,percentage:$percentage}'
      ''
    }/bin/waybar-${name}";
in {
  programs.waybar = {
    enable = true;
    #package = inputs.waybar.packages.${pkgs.system}.waybar;

    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };

    settings = {
      primary = {
        layer = "top";
        height = 15;
        margin = "5 5 0 5";
        position = "top";

        modules-left = [
          "pulseaudio"
          "battery"
          "custom/mail"
          #"hyprland/workspaces"
        ];
        #modules-center = [
        #  "mpd"
        #];
        modules-right = [ "tray" "hyprland/language" "clock" ];

        "hyprland/workspaces" = {
          active-only = true;
          all-outputs = true;
          sort-by = "id";
        };

        clock = {
          interval = 1;
          format = "{:%d.%m %H:%M}";
          format-alt = "{:%F %T %z}";
          tooltip-format = ''
            <tt><small>{calendar}</small></tt>
          '';
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            weeks-pos = "left";
            on-scroll = 1;
            format = let inherit (config.colorscheme) colors;
            in {
              months = "<span color='#${colors.base05}'><b>{}</b></span>";
              days = "<span color='#${colors.base05}'>{}</span>";
              weeks = "<span color='#${colors.base0D}'><b>{}</b></span>";
              weekdays = "<span color='#${colors.base0B}'><b>{}</b></span>";
              today = "<span color='#${colors.base0F}'><b>{}</b></span>";
            };
          };
          actions = {
            on-click-right = "mode";
            on-click-forward = "tz_up";
            on-click-backward = "tz_down";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };

        "hyprland/language" = {
          format = "{short} {variant}";
          #on-click = "${hyprctl} ${switchxkblayout}";
        };

        pulseaudio = {
          format = "{volume}";
          format-muted = "M";
          on-click = pavucontrol;
        };

        mpd = {
          interval = 3;
          format = "{artist} - {title}";
          on-click = "${alacritty} --class ncmpcpp -e ${ncmpcpp}";
          format-stopped = "";
          format-disconnected = "";
        };

        battery = {
          interval = 10;
          format = "{capacity}";
          format-charging = "{capacity}+";
          on-click = "";
        };

        tray = {
          icon-size = 15;
          spacing = 5;
        };

        "custom/clock" = {
          format = "{}";
          exec = "${date} +%H:%M";
          interval = 1;
        };

        "custom/date" = {
          format = "{}";
          exec = "${date} +%d-%m";
          interval = 60;
        };

        "custom/mail" = {
          interval = 1;
          format = "{}";
          return-type = "json";
          exec = jsonOutput "new-mails" {
            pre = let
              inherit (builtins) concatStringsSep attrValues filter;
              email_accounts = filter (acc: acc.mbsync.enable)
                (attrValues config.accounts.email.accounts);
            in ''
              total_count=$(${find} ${config.home.homeDirectory}/var/mail/*/Inbox/new -type f | ${wc} -l)

              ${concatStringsSep "\n" (map (acc: ''
                new_${acc.name}=$(${find} ${config.home.homeDirectory}/var/mail/${acc.name}/Inbox/new -type f | ${wc} -l)
              '') email_accounts)}

              tooltip=$(${printf} "${
                concatStringsSep "" (map (acc: ''
                  ${acc.name}: $new_${acc.name}
                '') email_accounts)
              }")

              if ${pgrep} mbsync &>/dev/null; then
                status="syncing"
              else if [ "$total_count" == "0" ]; then
                  status="read"
                else
                  status="unread"
                fi
              fi
            '';
            text = "$total_count";
            tooltip = "$tooltip";
          };
          on-click = "${alacritty} --class neomutt -e ${neomutt}";
        };
      };
    };

    # Cheatsheet:
    # x -> all sides
    # x y -> vertical, horizontal
    # x y z -> top, horizontal, bottom
    # w x y z -> top, right, bottom, left
    style = let
      inherit (config.colorscheme) colors;
      # css
    in ''
      * {
        border: none;
        border-radius: 5px;

        font-family: Share Tech Mono;
        font-size: 12pt;

        padding: 0 10px;
        margin: 0 5px;

        color: #${colors.base00};
      }

      tooltip {
        background: #${colors.base00};
        border: 2px solid #${colors.base09};
      }

      tooltip label {
        color: #${colors.base05};
      }

      window#waybar {
        background: transparent;
      }

      window#waybar.hidden {
        opacity: 0.2;
      }

      #pulseaudio, #clock {
        background: #${colors.base09};
      }

      #battery, #language {
        background: #${colors.base08};
      }

      #custom-mail, #tray {
        background: #${colors.base0C};
      }

      #battery.discharging.critical {
        background: #${colors.base0F};
      }


      #mpd {
        background: #${colors.base0C};
      }

      #mpd.disconnected,
      #mpd.stopped {
        color: transparent;
        background: transparent;
      }

    '';
  };
}
