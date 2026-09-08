{
  hostname,
  config,
  lib,
  ...
}:
{
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      defaultKeymap = "emacs";

      history = {
        path = "${config.home.homeDirectory}/.zhistory";
        size = 50000;
        save = 30000;
        extended = true;
        share = true;
        append = true;
        ignoreAllDups = true;
        saveNoDups = true;
        ignoreSpace = true;
        ignorePatterns = [
          "ls"
          "cd"
          "exit"
          "reboot"
        ];
      };

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
        disks = "echo '╓───── m o u n t . p o i n t s'; echo '╙────────────────────────────────────── ─ ─ '; lsblk -a; echo ''; echo '╓───── d i s k . u s a g e'; echo '╙────────────────────────────────────── ─ ─ '; df -h;";
      };

      initContent =
        let
          prompt_hostname_string = if hostname == "peasec" then "" else "(${hostname}) ";
        in
        ''
          setopt HIST_REDUCE_BLANKS
          setopt COMPLETE_ALIASES
          setopt correct

          zstyle ':completion:*' menu select

          # Collapses to …/last-three once the path gets deep.
          PROMPT="${prompt_hostname_string}%(4~|…/%3~|%~) » "

          # ALT+backspace deletes up to the next punctuation, not just to the
          # next whitespace like the default WORDCHARS does.
          my-backward-delete-word() {
            local WORDCHARS='~!#$%^&*(){}[]<>?+;'
            zle backward-delete-word
          }
          zle -N my-backward-delete-word
          bindkey '\e^?' my-backward-delete-word

          bindkey ' ' magic-space

          export XDG_DATA_DIRS="$XDG_DATA_DIRS:/usr/share:$HOME/.local/share/flatpak/exports/share";

          # per-core cpu temperature, straight from sysfs
          cpu-temp() {
            local name hwmon f
            for name in coretemp k10temp zenpower; do
              hwmon=$(grep -lx "$name" /sys/class/hwmon/hwmon*/name 2>/dev/null | head -1)
              [ -n "$hwmon" ] && break
            done
            if [ -z "$hwmon" ]; then
              echo "no cpu temperature sensor found" >&2
              return 1
            fi
            for f in "$(dirname "$hwmon")"/temp*_input; do
              printf '%-14s %3d°C\n' \
                "$(cat "''${f%_input}_label" 2>/dev/null || basename "$f" _input)" \
                "$(( $(cat "$f") / 1000 ))"
            done
          }
        ''
        + lib.strings.optionalString config.custom.nvim.enable ''
          export MANPAGER='nvim --cmd ":lua vim.g.noplugins=1" +Man!'
          export MANWIDTH=999
          export VISUAL=nvim
        '';
    };

    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
