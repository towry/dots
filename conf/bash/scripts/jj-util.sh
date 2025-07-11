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

  # use simple numbered menu for selection
  echo "Select next revision:" >&2
  local i=1
  local revision_array=()

  while IFS= read -r revision_line; do
    echo "  $i) $revision_line" >&2
    local change_id=$(echo "$revision_line" | awk -F'[][]' '{print $2}')
    revision_array+=("$change_id")
    ((i++))
  done <<< "$filtered_output"

  local selection
  while true; do
    echo -n "Enter number (1-$((i-1))): " >&2
    read -r selection

    if [[ "$selection" =~ ^[0-9]+$ ]] && [[ "$selection" -ge 1 ]] && [[ "$selection" -le $((i-1)) ]]; then
      echo "${revision_array[$((selection-1))]}"
      return 0
    else
      echo "Invalid selection. Please enter a number between 1 and $((i-1))." >&2
    fi
  done
}

# Check if we're in a jj repository
function __jj_util_check_repo() {
    if ! jj root >/dev/null 2>&1; then
        echo "Error: Not in a jj repository" >&2
        return 1
    fi
}

# Check if we're in an interactive shell
function __jj_util_is_interactive() {
    # Multiple checks for interactive shell detection
    # 1. Check if stdin and stdout are terminals
    # 2. Check if we can access /dev/tty (more reliable for subshells)
    # 3. Check for common interactive shell indicators

    # Primary check: terminal file descriptors
    if [[ -t 0 ]] && [[ -t 1 ]]; then
        return 0
    fi

    # Secondary check: can we access /dev/tty?
    if [[ -r /dev/tty ]] && [[ -w /dev/tty ]]; then
        return 0
    fi

    # Tertiary check: common interactive environment variables
    if [[ -n "$PS1" ]] || [[ -n "$TERM_PROGRAM" ]] || [[ "$TERM" != "dumb" ]]; then
        return 0
    fi

    return 1
}

# Get bookmarks from ancestors of current revision
function __jj_util_get_ancestor_bookmarks() {
    local current_rev="@"

    # Use jj log to traverse ancestors and find bookmarks, excluding old commits from trunk
    # Template outputs: change_id \t bookmarks (if any)
    # NOTE: Using trunk()..@ to exclude old master/main commits from search
    local log_output

    if ! log_output=$(jj log --no-pager --no-graph --color never -n 20 --template 'change_id.shortest(7) ++ "\t" ++ bookmarks ++ "\n"' -r 'trunk()..@' 2>/dev/null); then
        echo "Error: Failed to get ancestor log" >&2
        return 1
    fi

    # Filter lines that have bookmarks (non-empty bookmark field)
    # Format: change_id \t bookmark_name(s)
    local filtered_bookmarks
    filtered_bookmarks=$(echo -e "$log_output" | grep -E '^[a-z0-9]+\t.+$' | grep -v -E '\t$' | while read -r line; do
        local change_id=$(echo "$line" | cut -f1)
        local bookmarks_field=$(echo "$line" | cut -f2)

        # Handle multiple bookmarks (space-separated)
        for bookmark in $bookmarks_field; do
            # Skip empty or whitespace-only bookmarks
            if [[ -n "$bookmark" && "$bookmark" != " " ]]; then
                # Remove the asterisk (*) marker that indicates the current bookmark
                local clean_bookmark=$(echo "$bookmark" | sed 's/\*$//')
                echo -e "${change_id}\t${clean_bookmark}"
            fi
        done
    done)

    if [[ -z "$filtered_bookmarks" ]]; then
        echo "No bookmarks found in ancestors" >&2
        return 1
    fi

    # Prioritize local bookmarks over remote tracking bookmarks
    # First, try to find local bookmarks (without @remote suffix)
    local local_bookmarks
    local_bookmarks=$(echo "$filtered_bookmarks" | grep -v '@')

    if [[ -n "$local_bookmarks" ]]; then
        echo "$local_bookmarks"
    else
        # If no local bookmarks, fall back to remote tracking bookmarks
        echo "$filtered_bookmarks"
    fi
}

# Select bookmark interactively or automatically
function __jj_util_select_bookmark() {
    local bookmarks="$1"
    local line_count
    line_count=$(echo "$bookmarks" | wc -l)

    if [[ $line_count -eq 1 ]]; then
        # Only one bookmark, use it directly
        echo "$bookmarks" | awk -F'\t' '{print $2}'
        return 0
    fi

    if ! __jj_util_is_interactive; then
        echo "Error: Multiple bookmarks found but not in interactive shell" >&2
        echo "Available bookmarks:" >&2
        echo "$bookmarks" | awk -F'\t' '{print "  " $2 " (" $1 ")"}' >&2
        return 1
    fi

    # Interactive selection with simple numbered menu
    echo "Select bookmark:" >&2
    local i=1
    local bookmark_array=()

    while IFS=$'\t' read -r change_id bookmark_name; do
        echo "  $i) $bookmark_name ($change_id)" >&2
        bookmark_array+=("$bookmark_name")
        ((i++))
    done <<< "$bookmarks"

    local selection
    while true; do
        echo -n "Enter number (1-$((i-1))): " >&2
        read -r selection

        if [[ "$selection" =~ ^[0-9]+$ ]] && [[ "$selection" -ge 1 ]] && [[ "$selection" -le $((i-1)) ]]; then
            echo "${bookmark_array[$((selection-1))]}"
            return 0
        else
            echo "Invalid selection. Please enter a number between 1 and $((i-1))." >&2
        fi
    done
}

# Get target revision for bookmark
function __jj_util_get_target_revision() {
    local bookmark_name="$1"

    # Try to find commits with descriptions first
    local target_output
    if target_output=$(jj log --no-pager --no-graph --color never --template '"[" ++ change_id.shortest(7) ++ "] " ++ description.first_line()' -r "$bookmark_name..@ & ~description(exact:\"\")" --limit 10 2>/dev/null) && [[ -n "$target_output" ]]; then
        # Filter valid revisions (must have change ID and meaningful description)
        # Skip lines that have no description, empty description, or generic placeholder descriptions
        local filtered_targets
        filtered_targets=$(echo -e "$target_output" | grep -E '^\[[a-z0-9]+\]' | grep -v '^\[[a-z0-9]+\]$' | grep -v '^\[[a-z0-9]+\] *$' | grep -v '(no description set)' | grep -v "^$")

        if [[ -n "$filtered_targets" ]]; then
            local line_count
            line_count=$(echo "$filtered_targets" | wc -l)

            if [[ $line_count -eq 1 ]]; then
                # Only one revision, extract change ID
                local change_id
                change_id=$(echo "$filtered_targets" | awk -F'[][]' '{print $2}')
                echo "$change_id"
                return 0
            fi

            if ! __jj_util_is_interactive; then
                echo "Error: Multiple target revisions found but not in interactive shell" >&2
                echo "Available target revisions for '$bookmark_name' (with descriptions):" >&2
                echo "$filtered_targets" >&2
                return 1
            fi

            # Interactive selection with simple numbered menu
            echo "Select target revision for '$bookmark_name':" >&2
            local i=1
            local revision_array=()

            while IFS= read -r revision_line; do
                echo "  $i) $revision_line" >&2
                local change_id=$(echo "$revision_line" | awk -F'[][]' '{print $2}')
                revision_array+=("$change_id")
                ((i++))
            done <<< "$filtered_targets"

            local selection
            while true; do
                echo -n "Enter number (1-$((i-1))): " >&2
                read -r selection

                if [[ "$selection" =~ ^[0-9]+$ ]] && [[ "$selection" -ge 1 ]] && [[ "$selection" -le $((i-1)) ]]; then
                    echo "${revision_array[$((selection-1))]}"
                    return 0
                else
                    echo "Invalid selection. Please enter a number between 1 and $((i-1))." >&2
                fi
            done
        fi
    fi

    # No suitable target found - bookmark is already at the best position
    echo "No suitable descendant revision found for bookmark '$bookmark_name'" >&2
    echo "The bookmark appears to already be at the latest meaningful commit" >&2
    echo "or there are no revisions with descriptions ahead of it" >&2
    return 1
}

# Move bookmark to target revision
function __jj_util_move_bookmark() {
    local bookmark_name="$1"
    local target_change_id="$2"

    echo "Moving bookmark '$bookmark_name' to revision '$target_change_id'..."

    # Use jj bookmark move command with performance flags
    # The correct syntax is: jj bookmark move <bookmark_name> --to <target_revision>
    if ! jj bookmark move --no-pager "$bookmark_name" --to "$target_change_id"; then
        echo "Error: Failed to move bookmark '$bookmark_name' to '$target_change_id'" >&2
        return 1
    fi

    echo "Successfully moved bookmark '$bookmark_name' to revision '$target_change_id'"
}
