#!/usr/bin/env bash


# Use fzf to fuzzy find a directory from the file

if [ $# -eq 0 ]; then
    selected_dir=$(zoxide query -l | fzf)
else
    existing_session=$(tmux ls -F "#S" | grep "^$1$")

    if [ ! -z "$existing_session" ]; then
        echo "Attaching to existing session"
        tmux attach-session -t "$existing_session"
        exit 0
    fi

    selected_dir=$(zoxide query -l | grep -i $1)
fi

# Check if the selection is empty (user pressed ESC or didn't select anything)
if [ -z "$selected_dir" ]; then
  echo "No directory selected. Exiting."
  exit 0
fi

if [ $(wc -w <<< $selected_dir) -gt 1 ]; then
    echo "Unambigous query. Found:"
    nl <<< $selected_dir
    selected_dir=$(head -n1 <<< $selected_dir)
    echo "Selecting first: $selected_dir"
fi

# Get the basename of the selected directory
session_name=$(basename "$selected_dir")

# Check if a tmux session with the same name already exists
if tmux has-session -t "$session_name" 2>/dev/null; then
  # If the session already exists, attach to it
  tmux attach-session -t "$session_name"
else
  # If the session does not exist, create a new session in the selected directory
  cd "$selected_dir"
  tmux new-session -s "$session_name"
fi

