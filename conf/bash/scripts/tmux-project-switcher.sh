#!/usr/bin/env bash

# tmux-project-switcher.sh
# A flexible project switcher for tmux with multiple open modes

show_help() {
    cat << EOF
Usage: $0 [OPTIONS] [PATH]

Options:
    -h, --help      Show this help message
    -s, --session   Open in new session (default)
    -l, --right     Open in right pane
    -j, --bottom    Open in bottom pane
    -t, --window    Open in new window

If PATH is provided, use it directly. Otherwise, show interactive selector.
EOF
}

# Parse command line arguments
MODE="session"  # default mode
SELECTED_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -s|--session)
            MODE="session"
            shift
            ;;
        -l|--right)
            MODE="right"
            shift
            ;;
        -j|--bottom)
            MODE="bottom"
            shift
            ;;
        -t|--window)
            MODE="window"
            shift
            ;;
        -*)
            echo "Unknown option: $1" >&2
            show_help
            exit 1
            ;;
        *)
            SELECTED_PATH="$1"
            shift
            ;;
    esac
done

# Exit if current session is FLOAT
current_session=$(tmux display-message -p '#{session_name}')
if [[ $current_session == "FLOAT" ]]; then
    exit
fi

# If SELECTED_PATH is provided as argument, clean it immediately
if [[ -n $SELECTED_PATH ]]; then
    # Extract path from selection (remove git branch info) and expand tilde
    SELECTED_PATH=$(echo "$SELECTED_PATH" | awk -F '[' '{print $1}' | awk '{$1=$1;print}' | sed "s|^~|$HOME|")
fi

# If no path provided, show interactive selector
if [[ -z $SELECTED_PATH ]]; then
    # Create FZF keybindings for different modes
    SCRIPT_PATH="$(realpath "$0")"
    FZF_OPTS=(
        --tmux 95%
        --reverse
        --preview-window="down,30%,border-top"
        --tiebreak=index
        -1 -0
        --exact
        --bind "ctrl-s:become(\"$SCRIPT_PATH\" --session {})"
        --bind "ctrl-l:become(\"$SCRIPT_PATH\" --right {})"
        --bind "ctrl-j:become(\"$SCRIPT_PATH\" --bottom {})"
        --bind "ctrl-t:become(\"$SCRIPT_PATH\" --window {})"
        --header "ctrl-s:session | ctrl-l:right pane | ctrl-j:bottom pane | ctrl-t:window"
    )

    # Use binaries from PATH (assumes they're available)
    selected=$(zoxide query -l --exclude "$PWD" | \
        agpod vcs-path-info --filter --no-bare --format "{path} [{branch}]" | \
        awk -v home="$HOME" '{gsub(home, "~"); print}' | \
        fzf "${FZF_OPTS[@]}" \
            --preview "echo {} | awk -F '[' '{print \$1}' | awk -v home=\"\$HOME\" '{sub(/^~/,home)};1' | xargs -I % eza --color=always --icons=auto --group-directories-first --git --no-user --no-quotes --git-repos %" | \
        awk -v home="$HOME" '{sub(/^~/, home)};1')

    if [[ -z $selected ]]; then
        exit 0
    fi

    SELECTED_PATH=$selected
    # Extract path from selection (remove git branch info) and expand tilde
    SELECTED_PATH=$(echo "$SELECTED_PATH" | awk -F '[' '{print $1}' | awk '{$1=$1;print}' | sed "s|^~|$HOME|")
fi

# Use the cleaned path
clean_path="$SELECTED_PATH"
session_name="${clean_path##*/}"

# Handle different modes
case $MODE in
    session)
        # Original session behavior
        if [[ -z $TMUX ]]; then
            tmux new-session -s "$session_name" -c "$clean_path"
            exit 0
        fi

        if ! tmux has-session -t "$session_name" 2>/dev/null; then
            tmux new-session -ds "$session_name" -c "$clean_path"
        fi

        tmux switch-client -t "$session_name"
        ;;
    right)
        # Open in right pane
        if [[ -n $TMUX ]]; then
            tmux split-window -h -c "$clean_path"
        else
            echo "Error: Not in a tmux session" >&2
            exit 1
        fi
        ;;
    bottom)
        # Open in bottom pane
        if [[ -n $TMUX ]]; then
            tmux split-window -v -c "$clean_path"
        else
            echo "Error: Not in a tmux session" >&2
            exit 1
        fi
        ;;
    window)
        # Open in new window
        if [[ -n $TMUX ]]; then
            tmux new-window -c "$clean_path"
        else
            echo "Error: Not in a tmux session" >&2
            exit 1
        fi
        ;;
    *)
        echo "Error: Unknown mode: $MODE" >&2
        exit 1
        ;;
esac
