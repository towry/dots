#!/bin/bash

# Configuration - update these values for your project
TARGET_BRANCH="master"
# REMOVE_SOURCE_BRANCH="1"  # Commented out - this parameter causes 500 error when used in URL
                            # You'll need to manually check the checkbox in the GitLab UI

# Check if branch argument is provided
if [ $# -eq 0 ]; then
    echo "Error: Branch name is required"
    echo "Usage: $0 <branch>"
    exit 1
fi

BRANCH="$1"

# Get the latest commit message from the specified branch
COMMIT_MESSAGE=$(git log -1 --pretty=format:"%s" "$BRANCH" 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "Error: Could not get commit message from branch '$BRANCH'"
    echo "Make sure the branch exists and you're in a git repository"
    exit 1
fi

# Prefix with WIP:
PR_TITLE="WIP: $COMMIT_MESSAGE"

# Get git remote URL
REMOTE_URL=$(git remote get-url origin 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "Error: Could not get git remote URL"
    echo "Make sure you're in a git repository with an 'origin' remote"
    exit 1
fi

# Parse the remote URL
# Handle different SSH and HTTPS formats:
# 1. SSH format: git@host:port/path/repo.git
# 2. SSH URL format: ssh://git@host:port/path/repo.git
# 3. HTTPS format: https://host/path/repo.git
# Convert to: https://host/path/repo
if [[ $REMOTE_URL == ssh://git@* ]]; then
    # SSH URL format: ssh://git@host:port/path/repo.git
    # Remove ssh://git@ prefix and .git suffix
    HOST_PORT_PATH=$(echo "$REMOTE_URL" | sed 's|ssh://git@||' | sed 's/\.git$//')

    # Split by first slash to separate host:port from path
    HOST_PORT=$(echo "$HOST_PORT_PATH" | cut -d'/' -f1)
    PATH_PART=$(echo "$HOST_PORT_PATH" | cut -d'/' -f2-)

    # Extract host (everything before the colon)
    HOST=$(echo "$HOST_PORT" | cut -d':' -f1)

    WEB_BASE_URL="https://$HOST/$PATH_PART"
elif [[ $REMOTE_URL == git@* ]]; then
    # SSH format: git@host:port/path/repo.git
    # Extract everything after git@
    HOST_AND_PATH=$(echo "$REMOTE_URL" | sed 's/git@//' | sed 's/\.git$//')

    # Split by first colon to separate host from port/path
    HOST=$(echo "$HOST_AND_PATH" | cut -d':' -f1)
    PORT_AND_PATH=$(echo "$HOST_AND_PATH" | cut -d':' -f2-)

    # Check if there's a port number (numeric at start)
    if [[ $PORT_AND_PATH =~ ^[0-9]+/ ]]; then
        # Extract path after port number
        PATH_PART=$(echo "$PORT_AND_PATH" | sed 's/^[0-9]*\///')
    else
        # No port, the whole thing is the path
        PATH_PART="$PORT_AND_PATH"
    fi

    WEB_BASE_URL="https://$HOST/$PATH_PART"
elif [[ $REMOTE_URL == https://* ]]; then
    # Already HTTPS, just remove .git suffix
    WEB_BASE_URL=$(echo "$REMOTE_URL" | sed 's/\.git$//')
else
    echo "Error: Unsupported remote URL format: $REMOTE_URL"
    echo "Supported formats:"
    echo "  - git@host:port/path/repo.git"
    echo "  - ssh://git@host:port/path/repo.git"
    echo "  - https://host/path/repo.git"
    exit 1
fi

# NOTE: Avoid manual URL encoding to prevent double-encoding by macOS `open` or browsers
# Previously we encoded parameter names (merge_request%5B...%5D) and values, which resulted
# in sequences like %255B and %252F. Use raw bracketed keys and raw values instead and let
# the system handle proper escaping.

# Construct the PR creation URL
PR_URL="${WEB_BASE_URL}/merge_requests/new"
PR_URL="${PR_URL}?merge_request[description]="
PR_URL="${PR_URL}&merge_request[source_branch]=${BRANCH}"
PR_URL="${PR_URL}&merge_request[target_branch]=${TARGET_BRANCH}"
PR_URL="${PR_URL}&merge_request[title]=${PR_TITLE}"

# Debug output
echo "Parsed web URL: $WEB_BASE_URL"
echo "PR Title: $PR_TITLE"
echo "Source branch: $BRANCH"
echo "Target branch: $TARGET_BRANCH"
echo ""

# Open the URL in the default browser
if command -v open >/dev/null 2>&1; then
    # macOS
    open "$PR_URL"
    echo "✅ PR creation URL opened in browser (macOS)"
elif command -v xdg-open >/dev/null 2>&1; then
    # Linux
    xdg-open "$PR_URL"
    echo "✅ PR creation URL opened in browser (Linux)"
elif command -v start >/dev/null 2>&1; then
    # Windows
    start "$PR_URL"
    echo "✅ PR creation URL opened in browser (Windows)"
else
    echo "⚠️  Could not open browser automatically. Please open this URL manually:"
    echo "$PR_URL"
fi
