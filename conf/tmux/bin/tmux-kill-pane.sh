#!/usr/bin/env bash

pane_count=$(tmux list-panes | wc -l)
window_count=$(tmux list-windows | wc -l)
session_count=$(tmux list-sessions | wc -l)

if [ "$pane_count" -gt 1 ] || [ "$window_count" -gt 1 ]; then
  tmux kill-pane
else
  # Get the current session name
  target_session=$(tmux display-message -p "#S")
  next_session=$(tmux list-sessions | head -n 1 | awk "{print \$1}")
  if [ "$session_count" -gt 1 ] && [ -n "$next_session" ]; then
    tmux switch-client -l
    tmux confirm-before -p "kill session: $target_session (y/n) ?" "kill-session -t '$target_session'"
  else
    tmux confirm-before -p "kill current pane (y/n) ?" "kill-pane"
  fi
fi

exit 0

