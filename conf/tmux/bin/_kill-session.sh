
## check current session isnt '0'
## then switch back to session '0' and kill this session

current_session=$(tmux display-message -p | sed -e 's/^\[//' -e 's/\].*//')
if [[ "$current_session" != "0" ]]; then
  tmux switch-client -t "0"
  tmux kill-session -t "$current_session"
fi
