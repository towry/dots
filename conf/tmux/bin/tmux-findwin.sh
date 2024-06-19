#!/usr/bin/env bash

# Inspired by: https://github.com/rulopimentel/tmux-fzf-windows

# Sessions, windows and pane titles
TARGET_SPEC="#{session_id}:#{window_id} #{session_name} -> #{window_name} #{pane_title}"

# Select window
LINE=$(tmux list-windows -a -F "$TARGET_SPEC" | fzf --delimiter " " --with-nth 2..) || exit 0

# Split the result
args=(${LINE//:/ })

# Activate session/window/
tmux switch-client -t "${args[0]}"
tmux select-window -t "${args[1]}"
