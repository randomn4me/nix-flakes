#!/usr/bin/env bash

if [ $# -eq 0 ]; then
    selected_dir=$(fd -td . "$HOME" | fzf)

    # Check if the selection is empty (user pressed ESC or didn't select anything)
    if [ -z "$selected_dir" ]; then
        echo "No directory selected. Exiting."
        exit 0
    fi

    echo "$selected_dir"

    # Get the basename of the selected directory
    session_name=$(basename "$selected_dir")

    if [ -n "$TMUX" ]; then
        tmux new-session -c "$selected_dir" -s "$session_name" -d
        tmux switch-client -t "$session_name"
    else
        tmux new-session -c "$selected_dir" -s "$session_name"
    fi
else
    # predefined sessions: mail, obsidian
    echo given $1
    case "$1" in
        mail)
            if tmux has -t "$1"; then
                tmux at -t "$1"
            else
                if [ -n "$TMUX" ]; then
                    tmux new -d -e "TERM=screen-256color-bce" -s mail neomutt
                    tmux switch-client -t mail
                else
                    tmux new -e "TERM=screen-256color-bce" -s mail neomutt
                fi
            fi
            exit 1
            ;;
        obs*)
            if tmux has -t "$1"; then
                tmux at -t "$1"
            else
                if [ -n "$TMUX" ]; then
                    tmux new -d -e "TERM=screen-256color-bce" -c "$HOME/usr/docs/vault" -s obsidian nvim .
                    tmux switch-client -t obsidian
                else
                    tmux new -e "TERM=screen-256color-bce" -c "$HOME/usr/docs/vault" -s obsidian nvim .
                fi
            fi
            exit 1
            ;;
    esac

    user_input=$(tmux ls -F '#{session_name}' | grep "$1")

    if [ -z "$user_input" ]; then
        echo "no fitting session for $1"
        exit 1
    fi

    if [ "$(echo "$user_input" | wc -l)" -gt 1 ]; then
        session_name=$(echo "$user_input" | fzf)
    else
        session_name=$user_input
    fi

    tmux attach-session -t "$session_name"
fi
