#!/bin/bash

# get-owner-repo.sh - Detect jj/git repository and extract owner/repo
# Outputs to stdout: "owner/repo" format
# Always exits with 0 on success, 1 on error

set -e

# Function to extract owner/repo from git remote URL
extract_owner_repo() {
    local remote_url="$1"
    # Handle SSH format: git@github.com:owner/repo.git
    if [[ "$remote_url" =~ git@github\.com:(.+)\.git$ ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi
    # Handle SSH format without .git: git@github.com:owner/repo
    if [[ "$remote_url" =~ git@github\.com:(.+)$ ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi
    # Handle HTTPS format: https://github.com/owner/repo.git
    if [[ "$remote_url" =~ https://github\.com/(.+)\.git$ ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi
    # Handle HTTPS format without .git: https://github.com/owner/repo
    if [[ "$remote_url" =~ https://github\.com/(.+)$ ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi
    return 1
}

# Check for jj repository first
if jj root > /dev/null 2>&1; then
    echo "Detected jj repository, getting git remote..." >&2
    # Get the remote URL from jj
    remote_output=$(jj git remote list 2>/dev/null || echo "")
    if [[ -z "$remote_output" ]]; then
        echo "Error: No git remote configured for jj repository" >&2
        exit 1
    fi
    # Extract URL (first line typically contains the URL)
    remote_url=$(echo "$remote_output" | head -n 1 | awk '{print $2}')
    if extract_owner_repo "$remote_url"; then
        exit 0
    fi
    echo "Error: Could not parse jj remote URL: $remote_url" >&2
    exit 1
fi

# Check for git repository
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Detected git repository, getting git remote..." >&2
    # Get the remote URL (default to origin)
    remote_url=$(git remote get-url origin 2>/dev/null || git remote -v | head -n 1 | awk '{print $2}')
    if [[ -z "$remote_url" ]]; then
        echo "Error: No remote configured for git repository" >&2
        exit 1
    fi
    if extract_owner_repo "$remote_url"; then
        exit 0
    fi
    echo "Error: Could not parse git remote URL: $remote_url" >&2
    exit 1
fi

echo "Error: Not a git or jj repository" >&2
exit 1