{ config, ... }: {
  programs.tmux = {
    enable = true;
    clock24 = true;
    extraConfig = let inherit (config.colorscheme) colors;
    in ''
      # source https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6
      set -g default-terminal "xterm-direct"
      set -sg terminal-overrides ",*:RGB"

      set -gw mode-keys vi

      set-option -g renumber-windows on  # otherwise we might end up with window-numbers 1 2 4 7
      set -g base-index 1

      set -g status-interval 5

      # source https://github.com/folke/tokyonight.nvim/blob/main/extras/tmux/tokyonight_night.tmux (modified)
      set -g mode-style "fg=#${colors.base05},bg=#3b4261"

      set -g message-style "fg=#${colors.base05},bg=#3b4261"
      set -g message-command-style "fg=#${colors.base05},bg=#3b4261"

      set -g pane-border-style "fg=#3b4261"
      set -g pane-active-border-style "fg=#${colors.base05}"

      set -g status "on"
      set -g status-justify "left"

      set -g status-style "fg=#${colors.base05},bg=#${colors.base01}"

      set -g status-left-length "100"
      set -g status-right-length "100"

      set -g status-left-style NONE
      set -g status-right-style NONE

      set -g status-left "#[fg=#${colors.base01},bg=#${colors.base05},bold] #S #[fg=#${colors.base05},bg=#${colors.base01},nobold,nounderscore,noitalics]"
      set -g status-right "#[fg=#${colors.base01},bg=#${colors.base01},nobold,nounderscore,noitalics]#[fg=#${colors.base05},bg=#${colors.base01}] #{prefix_highlight} #[fg=#3b4261,bg=#${colors.base01},nobold,nounderscore,noitalics]#[fg=#${colors.base05},bg=#3b4261] %Y-%m-%d  %I:%M %p #[fg=#${colors.base05},bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#${colors.base01},bg=#${colors.base05},bold] #h "
      if-shell '[ "$(tmux show-option -gqv "clock-mode-style")" == "24" ]' {
          set -g status-right "#[fg=#${colors.base01},bg=#${colors.base01},nobold,nounderscore,noitalics]#[fg=#${colors.base05},bg=#${colors.base01}] #{prefix_highlight} #[fg=#3b4261,bg=#${colors.base01},nobold,nounderscore,noitalics]#[fg=#${colors.base05},bg=#3b4261] %Y-%m-%d  %H:%M #[fg=#${colors.base05},bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#${colors.base01},bg=#${colors.base05},bold] #h "
      }

    setw -g window-status-activity-style "underscore,fg=#a9b1d6,bg=#${colors.base01}"
        setw -g window-status-separator ""
        setw -g window-status-style "NONE,fg=#a9b1d6,bg=#${colors.base01}"
        setw -g window-status-format "#[fg=#${colors.base01},bg=#${colors.base01},nobold,nounderscore,noitalics]#[default] #I  #W #F #[fg=#${colors.base01},bg=#${colors.base01},nobold,nounderscore,noitalics]"
        setw -g window-status-current-format "#[fg=#${colors.base01},bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#${colors.base05},bg=#3b4261,bold] #I  #W #F #[fg=#3b4261,bg=#${colors.base01},nobold,nounderscore,noitalics]"

# tmux-plugins/tmux-prefix-highlight support
        set -g @prefix_highlight_output_prefix "#[fg=#e0af68]#[bg=#${colors.base01}]#[fg=#${colors.base01}]#[bg=#e0af68]"
        set -g @prefix_highlight_output_suffix ""
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
