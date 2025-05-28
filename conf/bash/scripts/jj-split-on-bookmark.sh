#!/usr/bin/env bash

# man jj-split
# 1. jj split -r @ -i -d <bookmark> -m "WIP: empty message"
# 2. jj mv-next <bookmark>

# This script does:
# 1. Accept required argument -b for bookmark
# 2. Accept optional argument -ai for using ai to generate commit.

set -euo pipefail

BASH_SCRIPT_DIR="$HOME/.local/bash/scripts"
AI_COMMIT_CONTEXT_SCRIPT="$BASH_SCRIPT_DIR/jj-commit-context.sh"
JJ_AI_COMMIT_SCRIPT="$BASH_SCRIPT_DIR/jj-ai-commit.sh"

# Function to show usage
show_usage() {
    echo "Usage: <script> -b <bookmark> [-ai]"
    echo "Split current working copy and optionally generate AI commit message"
    echo ""
    echo "Arguments:"
    echo "  -b <bookmark>  Bookmark name (required)"
    echo ""
    echo "Options:"
    echo "  -ai            Use AI to generate commit message for the split commit"
    echo "  -h, --help     Show this help message"
    echo ""
    echo "Examples:"
    echo "  <script> -b feature-branch"
    echo "  <script> -b feature-branch -ai"
}

# Function to check if we're in a jj repository
check_jj_repo() {
    if ! jj status >/dev/null 2>&1; then
        echo "Error: Not in a jj repository" >&2
        exit 1
    fi
}

# Function to perform the split operation
perform_split() {
    local bookmark="$1"
    local use_ai="$2"

    echo "Performing split operation with bookmark: $bookmark"

    if ! jj split -r @ -i -d "$bookmark" -m "WIP: empty message"; then
        echo "Error: Split operation failed or was cancelled" >&2
        exit 1
    fi

    # Step 2: Extract the revision ID of the split commit from operation log
    echo "Extracting revision information..."

    # Get the most recent operation details to find the newly created revision
    op_output=$(jj op log -n 1 --no-graph --no-pager -d --color=never)

    # Extract the revision ID of the newly created commit
    # Looking for pattern like: "+ nsvmzqu a6c0ab3 WIP: empty message"
    rev=$(echo "$op_output" | grep -E "^\+ [a-z0-9]+ [a-z0-9]+ WIP: empty message" | sed -E 's/^\+ ([a-z0-9]+) .*/\1/')

    if [[ -z "$rev" ]]; then
        echo "Error: Could not extract revision ID from operation log" >&2
        echo "Operation log output was:" >&2
        echo "$op_output" >&2
        exit 1
    fi

    echo "Split created revision: $rev"

    # Step 3: Generate AI commit message if requested
    if [[ "$use_ai" == "true" ]]; then
        echo "Using AI to generate commit message for revision: $rev"

        # Generate commit message using AI and apply it
        if "$AI_COMMIT_CONTEXT_SCRIPT" "$rev" | aichat --role git-commit -S -c | "$JJ_AI_COMMIT_SCRIPT" "$rev"; then
            echo "Successfully applied AI-generated commit message to revision: $rev"
        else
            echo "Warning: AI commit message generation failed, keeping default message" >&2
        fi
    fi

    echo "Split operation completed successfully!"
    echo "Created revision: $rev with bookmark: $bookmark"
}

# Main function
main() {
    local bookmark=""
    local use_ai="false"

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -b)
                if [[ -z "${2:-}" ]]; then
                    echo "Error: -b requires a bookmark name" >&2
                    show_usage
                    exit 1
                fi
                bookmark="$2"
                shift 2
                ;;
            -ai)
                use_ai="true"
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                echo "Error: Unknown option $1" >&2
                show_usage
                exit 1
                ;;
        esac
    done

    # Check if bookmark is provided
    if [[ -z "$bookmark" ]]; then
        echo "Error: Bookmark name is required (-b option)" >&2
        show_usage
        exit 1
    fi

    # Check if we're in a jj repository
    check_jj_repo

    # Check if AI scripts exist when -ai is used
    if [[ "$use_ai" == "true" ]]; then
        if [[ ! -f "$AI_COMMIT_CONTEXT_SCRIPT" ]]; then
            echo "Error: AI commit context script not found: $AI_COMMIT_CONTEXT_SCRIPT" >&2
            exit 1
        fi
        if [[ ! -f "$JJ_AI_COMMIT_SCRIPT" ]]; then
            echo "Error: AI commit script not found: $JJ_AI_COMMIT_SCRIPT" >&2
            exit 1
        fi
        if ! command -v aichat >/dev/null 2>&1; then
            echo "Error: aichat command not found. Please install aichat for AI functionality." >&2
            exit 1
        fi
    fi

    # Perform the split operation
    perform_split "$bookmark" "$use_ai"
}

# Run main function with all arguments
main "$@"
