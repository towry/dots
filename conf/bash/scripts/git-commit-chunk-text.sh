#!/usr/bin/env bash

# This script will run the git commit command with input text
# Input text is long text with empty lines.
# The entire input (from file or stdin) is used as the commit message.
# Uses 'git commit -F -' to read the message from stdin, which supports multi-line messages with blank lines.
# Eg: echo -e "Title\n\nDescription line 1\nDescription line 2" | $0
#     $0 -f commit_message.txt
#     $0 < commit_message.txt

set -euo pipefail

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Commits changes using multi-line text input (title and body)"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -f, --file     Read commit message from file"
    echo ""
    echo "Examples:"
    echo "  echo -e 'Title\\n\\nDescription line 1\\nDescription line 2' | $0"
    echo "  $0 -f commit_message.txt"
    echo "  $0 < commit_message.txt"
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

    # Use git commit -F - to read the message from stdin
    echo "$input_text" | git commit -F -
}

# Run main function with all arguments
main "$@"
