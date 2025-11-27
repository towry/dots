#!/usr/bin/env bash
set -euo pipefail

# Wrapper for sgrep search with safety checks
# Prevents accidental indexing of large/wrong directories
# Supports both jj and git repositories

REPO_ROOT=""

# Check for jj repository first (jj often operates atop git)
if jj root &>/dev/null; then
    REPO_ROOT=$(jj root)
# Check for git repository
elif git rev-parse --git-dir &>/dev/null; then
    REPO_ROOT=$(git rev-parse --show-toplevel)
fi

if [[ -z "$REPO_ROOT" ]]; then
    echo "ERROR: Not inside a git or jj repository!"
    echo ""
    echo "Current directory: $(pwd)"
    echo ""
    echo "sgrep will index the entire directory which can be slow for large folders."
    echo "Please cd into the correct repository before running this command."
    exit 1
fi

echo "Repo: $REPO_ROOT"
echo ""

exec sgrep search "$@"
