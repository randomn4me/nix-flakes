#!/usr/bin/env bash

attach_start_session() {
    session_name="$1"
    shift 1

    if tmux has -t "$session_name"; then
        tmux at -t "$session_name"
    else
        if [ -n "$TMUX" ]; then
            tmux new -d -s "$session_name" "$@"
            tmux switchc -t "$@"
        else
            tmux new -s "$session_name" "$@"
        fi
    fi
    exit 0
}

if [ $# -eq 0 ]; then
    selected_dir=$(find ~/src ~/etc -maxdepth 3 -type d | fzf)

    # Check if the selection is empty (user pressed ESC or didn't select anything)
    if [ -z "$selected_dir" ]; then
        echo "No directory selected. Exiting."
        exit 1
    fi

    # Get the basename of the selected directory
    session_name=$(basename "$selected_dir")
    echo "$selected_dir $session_name"

    if [ -n "$TMUX" ]; then
        tmux new -c "$selected_dir" -s "$session_name" -d
        tmux switchc -t "$session_name"
    else
        tmux new -c "$selected_dir" -s "$session_name"
    fi
else
    # predefined sessions: mail, obsidian
    echo "given $1"
    case "$1" in
        mail)
            attach_start_session mail -e "TERM=screen-256color-bce" neomutt ;;
        obs*)
            attach_start_session obsidian -c "$HOME/usr/docs/obsidian" nvim ;;
        #mat*|iamb)
        #    attach_start_session matrix iamb ;;
        sig*)
            attach_start_session signal scli ;;
        mus*)
            attach_start_session music ncmpcpp ;;
    esac

    user_input=$(tmux ls -F '#{session_name}' | grep -i "$1")

    if [ -z "$user_input" ]; then
        echo "no session started with name $1"
        exit 1
    fi

    if [ "$(echo "$user_input" | wc -l)" -gt 1 ]; then
        session_name=$(echo "$user_input" | fzf)
    else
        session_name=$user_input
    fi

    attach_start_session "$session_name"
fi
