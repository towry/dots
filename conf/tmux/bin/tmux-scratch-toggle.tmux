#!/usr/bin/env bash

scratch_session_name="FLOAT"

if [[ $current_session == "FLOAT" ]]; then
    if [[ "$TMUX_IS_POPUP" == "1" ]]; then
        tmux detach
        exit 0
    fi
    tmux switch-client -l
    exit 0
fi

# if the scratch session doesn't exist, create it
tmux has-session -t $scratch_session_name 2>/dev/null
if [[ $? != 0 ]]; then
    cwd="$(tmux display-message -p '#{pane_current_path}')"
    tmux new-session -ds "$scratch_session_name" -c "$cwd"
fi

if [[ $1 == "toggle" ]]; then
    tmux switch-client -t "$scratch_session_name"
else
    tmux display-popup -e "TMUX_IS_POPUP=1" -b heavy -w 88% -h 88% -S fg=colour8,bg=default -E tmux attach -t "$scratch_session_name"
fi
