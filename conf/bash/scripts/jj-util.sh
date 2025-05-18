# provide some util functions for jj

# template string for jj commit message
JJ_TEMPLATE="\"'[' ++ change_id.shortest(7) ++ '] ' ++ description.first_line() ++ '\\n'\""
JJ_LOG_CMD_PRE="jj log --quiet --no-pager --no-graph --color never --template '\"[\" ++ change_id.shortest(7) ++ \"]\" ++ \"\\t\" ++ description.first_line() ++ \"\\n\"' -r"
FZF_CMD="fzf --cycle --tmux 98% --ansi --layout=reverse --scheme=path --bind='ctrl-y:execute-silent(echo {} | pbcopy)' --header='Enter: select line, Ctrl-Y: copy line'"

# get the next node of a revision
function __jj_util_get_next_changeid() {
  # jj log --quiet --no-pager --no-graph --color never -r "<rev>+ ~ description('private:')"
  # select next node that doesn't have private: in description
  local rev="$1"
  if [[ -z "$rev" ]]; then
    return 1
  fi

  # get the command output and parse the text, remove unused output.
  # then check line count, if only one line, extract change id and return
  # otherwise use fzf to select one and return
  # no private and no merges commits
  local cmd="$JJ_LOG_CMD_PRE \"$rev+ ~ description(\\\"private:\\\") ~ merges() ~ empty() \""
#   local cmd="$JJ_LOG_CMD_PRE \"$rev+\""
  local output=$(eval $cmd)

  # check empty output first
  if [[ -z "$output" ]]; then
    return 1
  fi

  # filter lines to ensure they match our format [changeid]\t description
  # and store in a temporary variable
  local filtered_output
  filtered_output=$(echo -e "$output" | grep -E '^\[[a-z0-9]+\].*')
  # check if we have any valid lines
  if [[ -z "$filtered_output" ]]; then
    return 1
  fi

  local line_count=$(echo "$filtered_output" | wc -l)
  if [[ $line_count -eq 1 ]]; then
    echo "$filtered_output" | awk -F'[][]' '{print $2}'
    return 0
  fi

  # use fzf to select one and return
  local selected
  selected=$(echo "$filtered_output" | eval $FZF_CMD)
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  echo "$selected" | awk -F'[][]' '{print $2}'
  return 0
}
