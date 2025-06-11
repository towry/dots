#!/usr/bin/env bash

# get context for llm jj commit message generation
# script should redirect output to stdout, so it can be used in a pipeline

# NOTE: This script limits the amount of context provided to avoid exceeding
# the AI model's token limits (max_input_tokens). Large diffs and too much
# commit history can cause "Exceed max_input_tokens limit" errors.
#
# IMPORTANT: jj diff returns exit code 3 (not the typical SIGPIPE exit code 141)
# when used in a pipeline with head. This is jj's way of handling SIGPIPE when
# the pipe is closed early. The script handles this by treating exit code 3 as
# acceptable in pipeline contexts.

## The context should include:

# 1. Changes in the specified revision (limited to avoid token overflow)
# 2. Last 2 commit messages (reduced for token efficiency)

## It should output in well formatted text

## Steps

### 1. check if repo is a jj repository, exit 1 if not
### 2. Get the revision argument (default to @)
### 3. Get changes for the specified revision
### 4. Get last 2 commit messages
### 5. Format the output in well formatted text
### 6. Redirect the output to stdout
### 7. Exit 0

set -euo pipefail

# Function to check if we're in a jj repository
check_jj_repo() {
    if ! jj status >/dev/null 2>&1; then
        echo "Error: Not in a jj repository" >&2
        exit 1
    fi
}

# Function to get the revision argument
get_revision() {
    local rev="${1:-@}"
    echo "$rev"
}

# Function to get changes for the specified revision
get_revision_changes() {
    local rev="$1"

    echo "=== STAGED CHANGES ==="
    echo
    # Show compact summary with file stats
    echo "Files changed:"
    jj diff -r "$rev" --stat --color=never --no-pager
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "Error: jj diff --stat failed with exit code: $exit_code" >&2
        exit $exit_code
    fi
    echo

    # Check if diff is too large
    local diff_lines=$(jj diff -r "$rev" --color=never --no-pager | wc -l | tr -d ' ')
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "Error: jj diff | wc -l failed with exit code: $exit_code" >&2
        exit $exit_code
    fi
    local max_diff_lines=100  # Conservative limit for token usage
    local minimal_threshold=200  # If diff is huge, use minimal output

    if [ "$diff_lines" -gt "$minimal_threshold" ]; then
        echo "Very large diff detected ($diff_lines lines). Showing minimal summary:"
        # For huge diffs, just show summary stats
        jj diff -r "$rev" --stat --color=never --no-pager
        local exit_code=$?
        if [ $exit_code -ne 0 ]; then
            echo "Error: jj diff --stat (minimal) failed with exit code: $exit_code" >&2
            exit $exit_code
        fi
        echo
        echo "... (full diff omitted due to size - $diff_lines lines total) ..."
    elif [ "$diff_lines" -gt "$max_diff_lines" ]; then
        echo "Large diff detected ($diff_lines lines). Showing truncated diff:"

        # Temporarily disable pipefail for this command to handle SIGPIPE gracefully
        # NOTE: jj diff returns exit code 3 (not 141) when used in a pipeline with head
        # This is jj's way of handling SIGPIPE when the pipe is closed early by head
        set +o pipefail
        jj diff -r "$rev" --color=never --no-pager | head -n "$max_diff_lines"
        local jj_exit_code=${PIPESTATUS[0]}  # Get exit code of jj diff
        local head_exit_code=${PIPESTATUS[1]:-0}  # Get exit code of head, default to 0 if not set
        set -o pipefail

        # Ignore SIGPIPE (exit code 141) and jj's exit code 3 which happens when head closes the pipe early
        if [ $jj_exit_code -ne 0 ] && [ $jj_exit_code -ne 141 ] && [ $jj_exit_code -ne 3 ]; then
            echo "Error: jj diff (truncated) failed with exit code: $jj_exit_code" >&2
            exit $jj_exit_code
        fi
        echo
        echo "... (diff truncated - $((diff_lines - max_diff_lines)) lines omitted) ..."
    else
        echo "Full diff:"
        jj diff -r "$rev" --color=never --no-pager
        local exit_code=$?
        if [ $exit_code -ne 0 ]; then
            echo "Error: jj diff (full) failed with exit code: $exit_code" >&2
            exit $exit_code
        fi
    fi
    echo
}

# Function to get last 2 commit messages using template
get_recent_commits() {
    local rev="$1"
    echo "=== RECENT COMMIT HISTORY ==="
    echo
    echo "Last 2 commits:"
    # Use template to format output similar to git log --oneline
    jj log -n 2 -r "..$rev" --no-pager --no-graph --color=never \
        -T 'change_id.short() ++ " " ++ description.first_line() ++ "\n"'
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "Error: jj log failed with exit code: $exit_code" >&2
        exit $exit_code
    fi
    echo
}

# Function to show usage
usage() {
    echo "Usage: $0 [revision]"
    echo "  revision: The revision to analyze (default: @)"
    echo "  Examples:"
    echo "    $0        # Analyze working copy (@)"
    echo "    $0 @-     # Analyze parent of working copy"
    echo "    $0 abc123 # Analyze specific revision"
    exit 1
}

# Main function
main() {
    # Check for help flag
    if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
        usage
    fi

    check_jj_repo

    local rev
    rev=$(get_revision "${1:-}")

    echo "Git Commit Context"
    echo "=================="
    echo

    get_revision_changes "$rev"
    get_recent_commits "$rev"

    echo "=== END OF CONTEXT ==="
}

# Run main function
main "$@"

exit 0
