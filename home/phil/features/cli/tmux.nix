{
    programs.tmux = {
        enable = true;
        clock24 = true;
        extraConfig = ''
          # https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6
          # set -ag terminal-overrides ",$TERM:RGB"
          set -g default-terminal "tmux-256color"
          set -sg terminal-overrides ",*:RGB"

          # Format for the active window:
          set-window-option -g window-status-current-format '#[fg=green,bg=black]#I:#W '

          # Format for inactive windows:
          set-window-option -g window-status-format '#I:#W '

          set -g status-left-length 50
          set -g status-right-length 50

          set -g status-justify centre
          set -g status-left '#[fg=green,bg=black] '

          set -g status-right ' #[fg=green,bg=black]'
          set -g status-right '#[fg=green,bg=black] #(date +"%Y-%m-%d %H:%M")'
        '';
    };
}
