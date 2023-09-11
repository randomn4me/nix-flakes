{ pkgs, ... }:

{
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;

      historySize = 10000;
      historyFile = "\${HOME}/.bash_history";
      historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
      historyIgnore = [ "ls" "cd" "exit" ];

      shellAliases = {
        ll = "ls -lhF --color=auto";
        la = "ls -ahF --color=auto";

        ".." = "cd ..";
        rm = "rm -i";
        mv = "mv -i";
        cp = "cp -r";
        mkdir = "mkdir -p";
        o = "xdg-open";

        cal = "cal -m";
        disks="echo '╓───── m o u n t . p o i n t s'; echo '╙────────────────────────────────────── ─ ─ '; lsblk -a; echo ''; echo '╓───── d i s k . u s a g e'; echo '╙────────────────────────────────────── ─ ─ '; df -h;";
      };

      sessionVariables = {
        PROMPT_DIRTRIM = 2;
      };

      bashrcExtra = ''
        export PS1="\w >> ";
      '';
    };
  };
}
