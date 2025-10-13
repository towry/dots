#!/usr/bin/env bash
#
# Script to run before starting a Claude session.
#
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIRO_BASE_DIR="${KIRO_BASE_DIR:-$(pwd)/llm/kiro}"

source "$SCRIPT_DIR/init-kiro.sh"

# Simple error logging function for use in --pr-list
log_error() {
    echo "Error: $1" >&2
}

function __claude_boot_parse_args() {
    local pr_description=""
    local pr_list=false
    local generate_prompt=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                echo "Usage: claude-boot.sh [options]"
                echo "Options:"
                echo "  --help, -h              Show this help message"
                echo "  --pr-new \"description\"  Create new PR folder with description"
                echo "  --pr-list               List and select existing PR folder (interactive)"
                echo "  --generate-prompt       Generate system prompt from context JSON"
                echo ""
                echo "Workflow:"
                echo "  1. Use --pr-list to select a PR folder interactively"
                echo "  2. Use --generate-prompt to create system prompt for Claude"
                echo "  3. The generated prompt includes PR context and instructions"
                exit 0
                ;;
            --pr-new)
                if [[ $# -lt 2 ]]; then
                    echo "Error: --pr-new requires a description"
                    exit 1
                fi
                pr_description="$2"
                shift 2
                ;;
            --pr-list)
                pr_list=true
                shift
                ;;
            --generate-prompt)
                generate_prompt=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    # Store parsed arguments in global variables
    CLAUDE_BOOT_PR_DESCRIPTION="$pr_description"
    CLAUDE_BOOT_PR_LIST="$pr_list"
    CLAUDE_BOOT_GENERATE_PROMPT="$generate_prompt"
}

# take json ctxt, return system prompt string or empty string
function __claude_generate_system_prompt() {
    local context_json="$1"

    if [[ -z "$context_json" ]]; then
        echo ""
        return 0
    fi

    # Check if minijinja-cli is available
    if ! command -v minijinja-cli &> /dev/null; then
        echo "Error: minijinja-cli is not installed or not in PATH" >&2
        echo ""
        return 1
    fi

    # Create a simple template for system prompt generation
    local template='
# Claude System Prompt

## Context
{% if pr_dir %}PR Directory: {{ pr_dir }}
{% endif %}{% if description %}Description: {{ description }}
{% endif %}{% if branch_name %}Branch: {{ branch_name }}
{% endif %}
## Instructions
Use the provided context to generate appropriate responses and assist with the task at hand.
{% if pr_dir %}
Refer to the PR folder structure for additional context and requirements.
{% endif %}'

    # Extract values from JSON context for minijinja-cli
    local pr_dir description branch_name
    pr_dir=$(echo "$context_json" | jq -r '.pr_dir // empty')
    description=$(echo "$context_json" | jq -r '.description // empty')
    branch_name=$(echo "$context_json" | jq -r '.branch_name // empty')

    # Build minijinja-cli command with variables
    local cmd="minijinja-cli --template '$template'"
    if [[ -n "$pr_dir" ]]; then
        cmd="$cmd -D pr_dir='$pr_dir'"
    fi
    if [[ -n "$description" ]]; then
        cmd="$cmd -D description='$description'"
    fi
    if [[ -n "$branch_name" ]]; then
        cmd="$cmd -D branch_name='$branch_name'"
    fi

    # Execute the command
    eval "$cmd" 2>/dev/null || echo ""
}

# must return json or empty json
# parse argv, delegate to kilo workflow, aggregate result json and return
function __claude_boot_run() {
    local context_json='{}'
    local pr_dir=""
    local description=""
    local branch_name=""

    # Handle PR creation or selection
    if [[ -n "$CLAUDE_BOOT_PR_DESCRIPTION" ]]; then
        # Create new PR - delegate to kiro (init-kiro.sh)
        local result
        result=$(init_kiro_pr_new "$CLAUDE_BOOT_PR_DESCRIPTION" 2>/dev/null)
        if [[ $? -eq 0 && -n "$result" ]]; then
            pr_dir=$(echo "$result" | jq -r '.pr_dir // empty')
            description="$CLAUDE_BOOT_PR_DESCRIPTION"
            # Extract branch name from directory path
            branch_name=$(basename "$pr_dir")
        fi
    elif [[ "$CLAUDE_BOOT_PR_LIST" == "true" ]]; then
        # List existing PRs - provide interactive selection when possible
        if [[ ! -d "$KIRO_BASE_DIR" ]]; then
            log_error "Kiro directory does not exist: $KIRO_BASE_DIR"
            return 1
        fi

        # Get list of PR folders
        local folders=()
        while IFS= read -r -d '' folder; do
            folders+=("$(basename "$folder")")
        done < <(find "$KIRO_BASE_DIR" -maxdepth 1 -type d -not -path "$KIRO_BASE_DIR" -print0 2>/dev/null | sort -z)

        if [[ ${#folders[@]} -eq 0 ]]; then
            log_error "No PR folders found in $KIRO_BASE_DIR"
            return 1
        fi

        local selected_folder=""

        # Interactive selection - always show menu unless explicitly disabled
        if [[ "${FORCE_NON_INTERACTIVE:-}" != "true" ]]; then
            echo "Available PR folders:" >&2
            echo "====================" >&2

            local i=1
            for folder in "${folders[@]}"; do
                # Try to get a brief description from DESIGN.md
                local folder_path="$KIRO_BASE_DIR/$folder"
                local brief_desc=""
                if [[ -f "$folder_path/DESIGN.md" ]]; then
                    brief_desc=$(head -n 5 "$folder_path/DESIGN.md" | grep -i "description\|overview\|summary" | head -n 1 | sed 's/^[#:-]*//' | xargs || echo "")
                fi
                if [[ -n "$brief_desc" ]]; then
                    echo "  $i) $folder - $brief_desc" >&2
                else
                    echo "  $i) $folder" >&2
                fi
                ((i++))
            done

            while true; do
                echo -n "Select a folder (1-${#folders[@]}): " >&2
                read -r selection

                if [[ "$selection" =~ ^[0-9]+$ ]] && [[ "$selection" -ge 1 ]] && [[ "$selection" -le ${#folders[@]} ]]; then
                    selected_folder="${folders[$((selection-1))]}"
                    break
                else
                    log_error "Invalid selection. Please enter a number between 1 and ${#folders[@]}"
                fi
            done
        else
            # Non-interactive mode: use most recent folder
            selected_folder="${folders[-1]}"
            log_error "Non-interactive mode: selecting most recent PR folder: $selected_folder"
        fi

        # Set the selected PR context
        pr_dir="$KIRO_BASE_DIR/$selected_folder"
        branch_name="$selected_folder"

        # Try to read description from DESIGN.md if available
        if [[ -f "$pr_dir/DESIGN.md" ]]; then
            description=$(head -n 20 "$pr_dir/DESIGN.md" | grep -i "description\|overview\|summary" | head -n 1 | sed 's/^[#:-]*//' | xargs || echo "")
        fi
    fi

    # Build context JSON
    if [[ -n "$pr_dir" ]]; then
        context_json=$(echo "$context_json" | jq --arg pr_dir "$pr_dir" '. + {pr_dir: $pr_dir}')
    fi
    if [[ -n "$description" ]]; then
        context_json=$(echo "$context_json" | jq --arg description "$description" '. + {description: $description}')
    fi
    if [[ -n "$branch_name" ]]; then
        context_json=$(echo "$context_json" | jq --arg branch_name "$branch_name" '. + {branch_name: $branch_name}')
    fi

    # Add timestamp to context
    context_json=$(echo "$context_json" | jq --arg timestamp "$(date -Iseconds)" '. + {timestamp: $timestamp}')

    echo "$context_json"
}

# Main execution function
function __claude_boot_main() {
    # Parse arguments
    __claude_boot_parse_args "$@"

    # Run the main logic and get context JSON
    local context_json
    context_json=$(__claude_boot_run)

    # If generate-prompt flag is set, generate system prompt
    if [[ "$CLAUDE_BOOT_GENERATE_PROMPT" == "true" ]]; then
        local system_prompt
        system_prompt=$(__claude_generate_system_prompt "$context_json")
        echo "$system_prompt"
    else
        # By default, return the JSON context
        echo "$context_json"
    fi
}

# Ensure KIRO_BASE_DIR exists
if [[ ! -d "$KIRO_BASE_DIR" ]]; then
    mkdir -p "$KIRO_BASE_DIR"
    echo "Info: Created Kiro directory: $KIRO_BASE_DIR" >&2
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed or not in PATH" >&2
    exit 1
fi

# Check if minijinja-cli is available
if ! command -v minijinja-cli &> /dev/null; then
    echo "Warning: minijinja-cli is not installed or not in PATH" >&2
    echo "System prompt generation will not work without it." >&2
fi

# Run main function with all arguments
__claude_boot_main "$@"
