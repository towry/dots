# use bat to see the tmux config
# in new vertical tmux split

#!/usr/bin/env bash

set -eu

tmux split-window -h -p 70 "bat -lsh $HOME/.config/tmux/tmux.conf"

