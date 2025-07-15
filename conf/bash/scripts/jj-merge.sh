#!/usr/bin/env bash
set -euo pipefail

# jj-merge.sh - Enhanced merge script for jujutsu
# Usage: jj-merge.sh <branch1> <branch2>
# Creates a merge commit with detailed branch information

function show_usage() {
    cat >&2 << 'EOF'
Usage: jj-merge.sh <branch1> <branch2> [branch3...]

Creates a merge commit with multiple parents and detailed commit message.

Arguments:
  branch1     The first parent (typically the main/base branch)
  branch2+    Additional branches to merge (one or more)

Examples:
  jj-merge.sh main feature-auth
  jj-merge.sh main feature-auth feature-ui hotfix-123

This creates a commit with message listing all merged branches.
EOF
}



function main() {
    local branches=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                branches+=("$1")
                ;;
        esac
        shift
    done

    # Validate arguments - need at least 2 branches
    if [[ ${#branches[@]} -lt 2 ]]; then
        echo "ERROR: At least 2 branches are required for merge" >&2
        show_usage
        exit 1
    fi

    local base_branch="${branches[0]}"
    local merge_branches=("${branches[@]:1}")  # All branches except the first

    # Create the merge commit with detailed message
    local commit_message="[JJ]: Merge branches

Base: $base_branch"

    # Add each merged branch
    for branch in "${merge_branches[@]}"; do
        commit_message+="
Merge: $branch"
    done

    # Execute the merge using jj new with all parents
    # Build the command with all -r flags
    local jj_cmd=(jj new --ignore-working-copy --no-edit)
    for branch in "${branches[@]}"; do
        jj_cmd+=(-r "$branch")
    done
    jj_cmd+=(-m "$commit_message")

    if "${jj_cmd[@]}"; then
        # Show the result
        jj log -r @ --no-pager >&2
    else
        echo "ERROR: Failed to create merge commit" >&2
        exit 1
    fi
}

# Run main function with all arguments
main "$@"
