{ config, ... }:
{
    programs.tmux = {
        enable = true;
        clock24 = true;
        extraConfig = let inherit (config.colorscheme) colors; in ''
          # https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6
          # set -ag terminal-overrides ",$TERM:RGB"
          set -g default-terminal "tmux-256color"
          set -sg terminal-overrides ",*:RGB"

          set -gw mode-keys vi

          set-option -g renumber-windows on  # otherwise we might end up with window-numbers 1 2 4 7
          set -g base-index 1

          set -g status-interval 5

          set -g status-bg "#${colors.base02}"
          set -g status-fg "#${colors.base05}"
        '';

        # plugins = with pkgs.tmuxPlugins; [
        #   yank
        #   {
        #     plugin = maildir-counter;
        #     extraConfig = ''
        #       set -g @maildir_unread_counter 'yes'
        #       set -g @maildir_counters '${home}/var/mail/audacis/Inbox/new|${home}/var/mail/personalvorstand//Inbox/new'
        #     '';
        #   }
        # ];
    };
}
