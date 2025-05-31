#!/usr/bin/env bash

# get context for llm git commit message generation
# script should redirect output to stdout, so it can be used in a pipeline

# NOTE: This script limits the amount of context provided to avoid exceeding
# the AI model's token limits (max_input_tokens). Large diffs and too much
# commit history can cause "Exceed max_input_tokens limit" errors.

## The context should include:

# 1. Staged changes (limited to avoid token overflow)
# 2. Current branch name
# 3. Last 2 commit messages (reduced from 5)

## It should output in well formatted text

## Steps

### 1. check if repo is dirty, exit 1 if not dirty
### 2. Get staged changes (with limits)
### 3. Get current branch name
### 4. Get last 2 commit messages
### 5. Format the output in well formatted text
### 6. Redirect the output to stdout
### 7. Exit 0

set -euo pipefail

# Function to check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        exit 1
    fi
}

# Function to check if repo has staged changes
check_staged_changes() {
    if ! git diff --cached --quiet; then
        return 0  # Has staged changes
    else
        echo "Error: No staged changes found. Please stage your changes first." >&2
        exit 1
    fi
}

# Function to get staged changes (with size limits)
get_staged_changes() {
    echo "=== STAGED CHANGES ==="
    echo
    # Show the actual diff with limits
    echo "Changes summary:"
    git --no-pager diff --cached --stat --color=never
    echo

    # Check if diff is too large
    local diff_lines=$(git --no-pager diff --cached --color=never | wc -l)
    local max_diff_lines=100

    if [ "$diff_lines" -gt "$max_diff_lines" ]; then
        echo "Large diff detected ($diff_lines lines). Showing first $max_diff_lines lines:"
        git --no-pager diff --cached --color=never | head -n "$max_diff_lines"
        echo
        echo "... (diff truncated for brevity) ..."
    else
        echo "Full diff:"
        git --no-pager diff --cached --color=never
    fi
    echo
}

# Function to get current branch name
get_current_branch() {
    echo "=== CURRENT BRANCH ==="
    echo
    local branch_name
    branch_name=$(git branch --show-current)
    if [[ -z "$branch_name" ]]; then
        branch_name="(detached HEAD)"
    fi
    echo "Branch: $branch_name"
    echo
}

# Function to get last 2 commit messages (reduced from 5)
get_recent_commits() {
    echo "=== RECENT COMMIT HISTORY ==="
    echo
    echo "Last 2 commits:"
    git --no-pager log --oneline -2 --color=never --decorate
    echo
}

# Main function
main() {
    check_git_repo
    check_staged_changes

    echo "Git Commit Context"
    echo "=================="
    echo

    get_current_branch
    get_staged_changes
    get_recent_commits

    echo "=== END OF CONTEXT ==="
}

# Run main function
main

exit 0
