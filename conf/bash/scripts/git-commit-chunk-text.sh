#!/usr/bin/env bash

# This script will run the git commit command with input text
# Input text is long text with empty lines.
# First line is commit message, rest is description.
# to make long description with line break, we need to use multiple `-m`
# Eg: git commit -m "title" -m "description line 1" -m "description line 2" .........

set -euo pipefail

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Commits changes using multi-line text input"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -f, --file     Read commit message from file"
    echo ""
    echo "Examples:"
    echo "  echo 'Title\n\nDescription line 1\nDescription line 2' | $0"
    echo "  $0 -f commit_message.txt"
    echo "  $0 < commit_message.txt"
}

# Function to process commit text and execute git commit
commit_with_text() {
    local input_text="$1"

    # Split input into lines and process
    local lines=()

    # Use readarray to split input into lines
    readarray -t lines <<< "$input_text"
    local line_count=${#lines[@]}

    # Check if we have at least one line
    if [[ $line_count -eq 0 ]]; then
        echo "Error: No commit message provided" >&2
        exit 1
    fi

    # First line is the commit title
    local commit_title="${lines[0]}"

    # Check if title is empty
    if [[ -z "$commit_title" ]]; then
        echo "Error: Commit title cannot be empty" >&2
        exit 1
    fi

    # Build git commit command
    local git_cmd=("git" "commit" "-m" "$commit_title")

    # Add description lines (skip first line and any immediately following empty lines)
    local in_description=false
    for ((i=1; i<line_count; i++)); do
        local current_line="${lines[i]}"

        # Skip empty lines immediately after title until we find content
        if [[ -z "$current_line" ]] && [[ "$in_description" == false ]]; then
            continue
        fi

        # Once we find content, we're in description mode
        in_description=true
        git_cmd+=("-m" "$current_line")
    done

    # Execute the git commit command
    echo "Executing: ${git_cmd[*]}"
    "${git_cmd[@]}"
}

# Main script logic
main() {
    local input_text=""
    local read_from_file=""

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -f|--file)
                if [[ -z "${2:-}" ]]; then
                    echo "Error: -f/--file requires a filename" >&2
                    exit 1
                fi
                read_from_file="$2"
                shift 2
                ;;
            *)
                echo "Error: Unknown option $1" >&2
                show_usage
                exit 1
                ;;
        esac
    done

    # Read input based on source
    if [[ -n "$read_from_file" ]]; then
        # Read from file
        if [[ ! -f "$read_from_file" ]]; then
            echo "Error: File '$read_from_file' not found" >&2
            exit 1
        fi
        input_text=$(cat "$read_from_file")
    elif [[ ! -t 0 ]]; then
        # Read from stdin (pipe or redirect)
        input_text=$(cat)
    else
        # No input source provided
        echo "Error: No input provided. Use -f to read from file or pipe/redirect input" >&2
        show_usage
        exit 1
    fi

    # Check if input is empty
    if [[ -z "$input_text" ]]; then
        echo "Error: No input provided" >&2
        exit 1
    fi

    # Process and commit
    commit_with_text "$input_text"
}

# Run main function with all arguments
main "$@"
