#!/bin/bash

# Enhanced jj bookmark list with FZF integration for multi-line items
# This script shows bookmarks with their [JJ]: ancestor descriptions and allows interactive selection
#
# REQUIREMENTS (DO NOT CHANGE):
# 1. MULTI-LINE DISPLAY: Each bookmark shows on its main line, followed by its special [JJ]: description on the next line
# 2. FORMAT:
#    bookmark-name: commit-info description
#          [JJ]: special description from ancestor
# 3. INDENTATION: [JJ]: descriptions must be indented with 6 spaces (      )
# 4. NO BRACKETS: Do not wrap [JJ]: descriptions in brackets or other markers
# 5. ANCESTOR SEARCH: Find the FIRST ancestor commit whose description starts with "[JJ]: "
# 6. OPTIONAL DISPLAY: Only show [JJ]: line if such ancestor exists
# 7. FZF INTEGRATION: Use NUL-separated items for proper multi-line handling
#
# Usage:
#   ./jj-bookmark-enhanced-fzf.sh           # Interactive FZF selection
#   ./jj-bookmark-enhanced-fzf.sh --list    # Plain list output (original behavior)
#   ./jj-bookmark-enhanced-fzf.sh --help    # Show help

set -euo pipefail

# Function to find first [JJ]: description in ancestors
# REQUIREMENT: Must find the FIRST ancestor commit with description starting with "[JJ]: "
find_jj_description() {
    local bookmark="$1"
    # Get ancestors and find the first one with [JJ]: prefix
    jj log --ignore-working-copy --no-pager --no-graph \
        -r "ancestors(\"$bookmark\") ~ merges()" \
        -T 'description' \
        | grep '^\[JJ\]:' | head -n1 || echo ""
}

# Generate bookmark list with multi-line format
# Returns NUL-separated items for FZF processing
generate_bookmark_list() {
    local output_format="$1"  # "fzf" or "plain"

    jj bookmark list --ignore-working-copy --no-pager --color=always \
        | grep -v '^[[:space:]]' | grep -v '\(deleted\)' \
        | while IFS= read -r line; do
            # Extract bookmark name (first field before colon), strip ANSI color codes
            bookmark_name=$(echo "$line" | cut -d: -f1 | sed 's/[[:space:]]*$//' | sed 's/\x1b\[[0-9;]*m//g')

            # For FZF mode, we need to build the entire item before outputting
            if [[ "$output_format" == "fzf" ]]; then
                # Build the multi-line item
                local item="$line"

                # REQUIREMENT: Find and print the special [JJ]: description if exists
                jj_desc=$(find_jj_description "$bookmark_name")
                if [[ -n "$jj_desc" ]]; then
                    item="${item}\n  ${jj_desc}"  # 6 spaces indentation - DO NOT CHANGE
                fi

                # Output the complete item followed by NUL separator
                printf "%b\0" "$item"
            else
                # Plain mode: original behavior
                echo "$line"

                # REQUIREMENT: Find and print the special [JJ]: description if exists
                jj_desc=$(find_jj_description "$bookmark_name")
                if [[ -n "$jj_desc" ]]; then
                    echo "      ${jj_desc}"  # 6 spaces indentation - DO NOT CHANGE
                fi
            fi
        done
}

# Extract bookmark name from selected FZF output
extract_bookmark_name() {
    local selected="$1"
    # Get the first line and extract bookmark name before colon, strip ANSI codes
    echo "$selected" | head -n1 | cut -d: -f1 | sed 's/[[:space:]]*$//' | sed 's/\x1b\[[0-9;]*m//g'
}

# Show help
show_help() {
    cat << EOF
Enhanced jj bookmark list with FZF integration

Usage:
  $0 [OPTIONS]

Options:
  --list    Show plain list output (original behavior)
  --help    Show this help message

Default behavior (no options):
  Interactive FZF selection of bookmarks with multi-line display

FZF Integration Features:
  - Multi-line display with proper item separation
  - Highlighted lines for better readability
  - Visual gaps between bookmark items
  - Custom markers for multi-line items
  - ANSI color support preserved

Examples:
  $0                    # Interactive bookmark selection
  $0 --list            # Plain list for piping to other tools
  $0 | head -5         # Show first 5 bookmarks (plain mode auto-detected)

After selection, the chosen bookmark name is printed to stdout.
EOF
}

# Main execution logic
main() {
    local mode="interactive"

    # Parse arguments
    case "${1:-}" in
        --list)
            mode="plain"
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        "")
            # Check if output is being piped - if so, default to plain mode
            if [[ ! -t 1 ]]; then
                mode="plain"
            fi
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Use --help for usage information" >&2
            exit 1
            ;;
    esac

    if [[ "$mode" == "plain" ]]; then
        # Original behavior - plain list output
        generate_bookmark_list "plain"
    else
        # Interactive FZF mode
        # Check if fzf is available
        if ! command -v fzf >/dev/null 2>&1; then
            echo "Error: fzf is not installed or not in PATH" >&2
            echo "Please install fzf or use --list for plain output" >&2
            exit 1
        fi

        # Generate NUL-separated list and pipe to FZF
        selected=$(generate_bookmark_list "fzf" | fzf \
            --read0 \
            --ansi \
            --layout=reverse \
            --highlight-line \
            --gap \
            --marker-multi-line='╔║╚' \
            --prompt='Select bookmark: ' \
            --header='↑↓ navigate • Enter select • Esc cancel' \
            --preview-window=hidden \
            --no-multi)

        # Handle user cancellation
        if [[ -z "$selected" ]]; then
            echo "No bookmark selected" >&2
            exit 1
        fi

        # Extract and print the bookmark name
        bookmark_name=$(extract_bookmark_name "$selected")
        echo "$bookmark_name"
    fi
}

# Run main function with all arguments
main "$@"
