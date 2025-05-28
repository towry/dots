#!/bin/bash

file=`mktemp`_tmux-output.sh
tmux capture-pane -pS -32768 > $file
tmux new-window -nedit-buffer "$EDITOR '+ normal G $' $file"
