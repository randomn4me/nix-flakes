{ osConfig, ... }:
{
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;

      historySize = 10000;
      historyFile = "\${HOME}/.bash_history";
      historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
      historyIgnore = [ "ls" "cd" "exit" "reboot" ];

      shellAliases = {
        ".." = "cd ..";

        # saveguard
        rm = "rm -i";
        mv = "mv -i";

        # shorter
        cp = "cp -r";
        mkdir = "mkdir -p";
        o = "xdg-open";

        cal = "cal -m";
        disks =
          "echo '╓───── m o u n t . p o i n t s'; echo '╙────────────────────────────────────── ─ ─ '; lsblk -a; echo ''; echo '╓───── d i s k . u s a g e'; echo '╙────────────────────────────────────── ─ ─ '; df -h;";
      };

      sessionVariables.PROMPT_DIRTRIM = 2;

      bashrcExtra = let
      hostname = osConfig.networking.hostName;
      ps1_hostname_string = if hostname == "work" then "" else "(${hostname}) ";
      in ''
        export PS1="${ps1_hostname_string}\w >> ";
        export XDG_DATA_DIRS="$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
      '';
    };
  };
}
