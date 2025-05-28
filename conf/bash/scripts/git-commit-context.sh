#!/usr/bin/env bash

# get context for llm git commit message generation
# script should redirect output to stdout, so it can be used in a pipeline

## The context should include:

# 1. Staged changes
# 2. Current branch name
# 3. Last 10 commit messages

## It should output in well formatted text

## Steps

### 1. check if repo is dirty, exit 1 if not dirty
### 2. Get staged changes
### 3. Get current branch name
### 4. Get last 10 commit messages
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

# Function to get staged changes
get_staged_changes() {
    echo "=== STAGED CHANGES ==="
    echo
    # Show the actual diff
    echo "Changes:"
    git --no-pager diff --cached --stat --color=never
    echo
    git --no-pager diff --cached --color=never
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

# Function to get last 10 commit messages
get_recent_commits() {
    echo "=== RECENT COMMIT HISTORY ==="
    echo
    echo "Last 10 commits:"
    git --no-pager log --oneline -10 --color=never --decorate
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
