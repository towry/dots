#!/bin/bash

# jj-tug.sh - Move bookmarks to specific revisions
# This script helps move bookmarks to target revisions, with interactive selection when needed

# 1. get bookmarks (branches) from ancestor, there maybe multiple, usually one.
# 2. if there is only one, use it, otherwise detect if it is interactive shell,
# 2.1 if is interactive shell, prompt user to select one with number index.
# 2.2 if not interactive shell, return error.
#
# 3. get the revision(commit in git) for the bookmark to move to, there maybe multiple revision.
# 4. if there is only one, use it, otherwise detect if it is interactive shell,
# 4.1 if is interactive shell, prompt user to select one with number index.
# 4.2 if not interactive shell, return error.
#
# when apply jj command, use --ignore-working-copy, and --no-pager, --no-graph, --color never for better perf.
# you may need to use jj template language to parse description and change_id.

## the revision to move to, usually is the latest commit of one branch/bookmark, but it should not be empty, should have description.

# revset doc: https://jj-vcs.github.io/jj/latest/revsets/
# template lang doc: https://jj-vcs.github.io/jj/latest/templates/
# jj command doc: https://jj-vcs.github.io/jj/latest/cli-reference/
##

## Please maintain the util function in the ./jj-util.sh file.

# Source utility functions
source "$(dirname "${BASH_SOURCE[0]}")/jj-util.sh"

# Main function
function main() {
    # Check if we're in a jj repository
    if ! __jj_util_check_repo; then
        return 1
    fi

    echo "Getting bookmarks from ancestors..."

    # Step 1: Get bookmarks from ancestors
    local ancestor_bookmarks
    if ! ancestor_bookmarks=$(__jj_util_get_ancestor_bookmarks); then
        return 1
    fi

    # Step 2: Select bookmark (interactive or automatic)
    echo "Selecting bookmark..."
    local selected_bookmark
    if ! selected_bookmark=$(__jj_util_select_bookmark "$ancestor_bookmarks"); then
        return 1
    fi

    echo "Selected bookmark: $selected_bookmark"

    # Step 3: Get target revision for the bookmark
    echo "Getting target revision for bookmark '$selected_bookmark'..."
    local target_revision
    if ! target_revision=$(__jj_util_get_target_revision "$selected_bookmark"); then
        return 1
    fi

    echo "Target revision: $target_revision"

    # Step 4: Move bookmark to target revision
    if ! __jj_util_move_bookmark "$selected_bookmark" "$target_revision"; then
        return 1
    fi

    echo "✓ jj-tug completed successfully"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
