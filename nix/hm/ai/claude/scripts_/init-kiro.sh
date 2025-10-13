#!/usr/bin/env bash

# init-kiro.sh - Kiro PR Management Script
#
# This script manages Kiro PR folders for structured development workflows.
# It creates PR-specific documentation and returns the directory path as JSON.
#
# USAGE METHODS:
#
# 1. EXECUTE MODE (JSON output for automation):
#    -----------------------------------------------
#    # Create new PR folder and get JSON output
#    /path/to/init-kiro.sh --pr-new "Add user authentication feature"
#    # Output: {"pr_dir":"/current/dir/llm/kiro/branch_name"}
#
#    # List and select existing PR folder (interactive only)
#    /path/to/init-kiro.sh --pr-list
#    # Output: {"pr_dir":"/current/dir/llm/kiro/selected_branch"}
#
#    # Parse JSON with jq
#    pr_dir=$(/path/to/init-kiro.sh --pr-new "description" | jq -r '.pr_dir')
#
# 2. SOURCE MODE (direct functions):
#    --------------------------------
#    # Source the script to get functions in current shell
#    source /path/to/init-kiro.sh
#
#    # Create new PR folder
#    init_kiro_pr_new "Add user authentication feature"
#    # Output: {"pr_dir":"/current/dir/llm/kiro/branch_name"}
#
#    # List existing PR folders (interactive)
#    init_kiro_pr_list
#    # Output: {"pr_dir":"/current/dir/llm/kiro/selected_branch"}
#
# REQUIREMENTS:
# - minijinja-cli (for template rendering)
# - aichat (for intelligent branch naming)
# - jq (for JSON parsing)
#
# FILES CREATED:
# - DESIGN.md: Technical requirements and design
# - CLAUDE.md: AI assistant instructions and workflow
# - TASK.md: Task tracking and progress management
#
# STRUCTURE:
# - Works in current working directory: ./llm/kiro/{branch_name}/
# - Templates from: $HOME/.dotfiles/nix/hm/ai/claude/assets/kiro/
# - Branch names use underscores instead of slashes for filesystem compatibility
# - Logs go to stderr, JSON output goes to stdout

set -euo pipefail

# Configuration
KIRO_BASE_DIR="${KIRO_BASE_DIR:-$(pwd)/llm/kiro}"
TEMPLATE_DIR="${TEMPLATE_DIR:-$HOME/.dotfiles/nix/hm/ai/claude/assets/kiro}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions (always output to stderr)
log_info() {
    if [[ "${KIRO_QUIET:-}" != "1" ]]; then
        echo -e "${BLUE}[INFO]${NC} $1" >&2
    fi
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Print usage information
show_usage() {
    cat << EOF
Usage: $0 [OPTION]

Initialize or work with Kiro PR folders.

Options:
    --pr-new "description"    Create a new PR folder with the given description
    --pr-list                 List existing PR folders and select one to work on
    -h, --help               Show this help message

Examples:
    $0 --pr-new "Add user authentication feature"
    $0 --pr-list

EOF
}

# Validate that a string is a valid git branch name
validate_branch_name() {
    local branch_name="$1"

    # Git branch name rules:
    # - Cannot start with a dot
    # - Cannot contain '..'
    # - Cannot contain spaces
    # - Cannot end with .lock
    # - Cannot contain special characters except: - _ . /

    if [[ -z "$branch_name" ]]; then
        return 1
    fi

    # Check for invalid patterns
    if [[ "$branch_name" =~ ^\. ]] || \
       [[ "$branch_name" =~ \.\. ]] || \
       [[ "$branch_name" =~ \.lock$ ]] || \
       [[ "$branch_name" =~ [\[:space:\]\~\^\:\?\*\[\]] ]]; then
        return 1
    fi

    return 0
}

# Generate branch name using aichat
generate_branch_name() {
    local description="$1"

    log_info "Generating branch name for: $description"

    # Try to generate branch name using aichat
    local branch_name
    branch_name=$(aichat --role git-branch -S -c "$description" 2>/dev/null || true)

    if [[ -n "$branch_name" ]]; then
        # Replace "/" with "_" for folder name
        local folder_name="${branch_name//\//_}"
        echo "$folder_name"
        return 0
    fi

    # Fallback: simple conversion
    local fallback="feature/$(echo "$description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')"
    local fallback_folder="${fallback//\//_}"

    echo "$fallback_folder"
    return 0
}

# List existing PR folders
list_pr_folders() {
    # Check if running in interactive mode
    if [[ ! -t 0 ]]; then
        log_error "pr-list requires interactive mode. Use it directly in terminal."
        return 1
    fi

    if [[ ! -d "$KIRO_BASE_DIR" ]]; then
        log_warning "Kiro directory does not exist: $KIRO_BASE_DIR"
        return 1
    fi

    local folders=()
    while IFS= read -r -d '' folder; do
        folders+=("$(basename "$folder")")
    done < <(find "$KIRO_BASE_DIR" -maxdepth 1 -type d -not -path "$KIRO_BASE_DIR" -print0 2>/dev/null | sort -z)

    if [[ ${#folders[@]} -eq 0 ]]; then
        log_warning "No PR folders found in $KIRO_BASE_DIR"
        return 1
    fi

    # Output folder listing to stderr for display only
    echo "Available PR folders:" >&2
    echo "====================" >&2

    local i=1
    for folder in "${folders[@]}"; do
        echo "  $i) $folder" >&2
        ((i++))
    done

    while true; do
        echo -n "Select a folder (1-${#folders[@]}): " >&2
        read -r selection

        if [[ "$selection" =~ ^[0-9]+$ ]] && [[ "$selection" -ge 1 ]] && [[ "$selection" -le ${#folders[@]} ]]; then
            local selected_folder="${folders[$((selection-1))]}"
            echo "$KIRO_BASE_DIR/$selected_folder"
            return 0
        else
            log_error "Invalid selection. Please enter a number between 1 and ${#folders[@]}"
        fi
    done
}

# Load template content from file
load_template_content() {
    local template_file="$1"
    local template_path="$TEMPLATE_DIR/$template_file"

    if [[ ! -f "$template_path" ]]; then
        log_error "Template file not found: $template_path"
        return 1
    fi

    cat "$template_path"
}

# Export system prompt from PR directory
export_system_prompt() {
    local pr_dir="$1"
    local claude_file="$pr_dir/CLAUDE.md"

    if [[ ! -f "$claude_file" ]]; then
        log_error "CLAUDE.md file not found: $claude_file"
        return 1
    fi

    # Read the CLAUDE.md content and export as environment variable
    local system_prompt
    system_prompt=$(cat "$claude_file")
    export KIRO_SYSTEM_PROMPT="$system_prompt"

    log_success "System prompt exported from: $claude_file"
}

# Create PR folder with template files
create_pr_folder() {
    local branch_name="$1"
    local description="$2"
    local pr_dir="$KIRO_BASE_DIR/$branch_name"

    if [[ -d "$pr_dir" ]]; then
        log_error "PR folder already exists: $pr_dir"
        exit 1
    fi

    log_info "Creating PR folder: $pr_dir"
    mkdir -p "$pr_dir"

    # Check if template directory exists
    if [[ ! -d "$TEMPLATE_DIR" ]]; then
        log_error "Template directory not found: $TEMPLATE_DIR"
        exit 1
    fi

    # Create template files using minijinja-cli
    log_info "Creating template files..."

    for template_file in "DESIGN.md" "CLAUDE.md" "TASK.md"; do
        # Load template content from file (using .hbs extension)
        local template_content
        template_content=$(load_template_content "$template_file.hbs")

        # Render template using minijinja-cli
        echo "$template_content" | minijinja-cli \
            -D "description=$description" \
            -D "branch_name=$branch_name" \
            - > "$pr_dir/$template_file"

        log_success "Created: $pr_dir/$template_file"
    done

    log_success "PR folder initialized successfully: $pr_dir"
    echo "$pr_dir"
}


# Main script logic
main() {
    # Handle no arguments case
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 0
    fi

    # Parse command line arguments
    case "${1:-}" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --pr-list)
            log_info "Listing existing PR folders..."
            pr_dir=$(list_pr_folders)
            if [[ -n "$pr_dir" ]]; then
                log_success "Selected PR folder: $pr_dir"
                export_system_prompt "$pr_dir"
                echo ""
                echo "KIRO_SYSTEM_PROMPT has been exported. You can now start your AI assistant with this environment."
            else
                log_error "No PR folders available"
                exit 1
            fi
            ;;
        --pr-new)
            if [[ $# -lt 2 ]]; then
                log_error "--pr-new requires a description"
                show_usage
                exit 1
            fi

            local description="$2"
            log_info "Creating new PR for: $description"

            # Generate branch name
            local branch_name
            branch_name=$(generate_branch_name "$description")

            if [[ -z "$branch_name" ]]; then
                log_error "Failed to generate branch name"
                echo -n "Please provide a valid branch name: "
                read -r branch_name

                if ! validate_branch_name "$branch_name"; then
                    log_error "Invalid branch name: $branch_name"
                    exit 1
                fi
            fi

            log_success "Using branch name: $branch_name"

            # Create PR folder
            local pr_dir
            pr_dir=$(create_pr_folder "$branch_name" "$description")

            # Export system prompt
            export_system_prompt "$pr_dir"

            echo ""
            echo "PR folder created and KIRO_SYSTEM_PROMPT exported successfully!"
            echo "Folder: $pr_dir"
            echo "Branch: $branch_name"
            ;;
        *)
            log_error "Unknown option: ${1:-}"
            show_usage
            exit 1
            ;;
    esac
}

# Check if script is being sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Script is being sourced - make functions available
    log_info "Kiro functions loaded. Use init_kiro_pr_new \"description\" or init_kiro_pr_list"
else
    # Script is being executed - run main function
    # Check if minijinja-cli is available
    if ! command -v minijinja-cli &> /dev/null; then
        log_error "minijinja-cli is not installed or not in PATH"
        exit 1
    fi

    # Check if aichat is available (for branch name generation)
    if ! command -v aichat &> /dev/null; then
        log_warning "aichat is not available. Will use fallback branch name generation."
    fi

    # Create kiro base directory if it doesn't exist
    mkdir -p "$KIRO_BASE_DIR"

    # Run main function with all arguments
    main "$@"
fi

# Convenience functions for when script is sourced
init_kiro_pr_new() {
    local description="$1"

    if [[ -z "$description" ]]; then
        log_error "Description is required"
        return 1
    fi

    log_info "Creating new PR for: $description"

    # Generate branch name
    local branch_name
    branch_name=$(generate_branch_name "$description")

    if [[ -z "$branch_name" ]]; then
        log_error "Failed to generate branch name"
        echo -n "Please provide a valid branch name: "
        read -r branch_name

        if ! validate_branch_name "$branch_name"; then
            log_error "Invalid branch name: $branch_name"
            return 1
        fi
    fi

    log_success "Using branch name: $branch_name"

    # Create PR folder
    local pr_dir
    pr_dir=$(create_pr_folder "$branch_name" "$description")

    # Output JSON result
    echo '{"pr_dir":"'"$pr_dir"'"}'
    log_info "PR folder created: $pr_dir"
    log_info "Branch: $branch_name"
}

init_kiro_pr_list() {
    # Check if running in interactive mode
    if [[ ! -t 0 ]]; then
        log_error "pr-list requires interactive mode. Use it directly in terminal."
        return 1
    fi

    log_info "Listing existing PR folders..."
    local pr_dir
    pr_dir=$(list_pr_folders)

    if [[ -n "$pr_dir" ]]; then
        log_success "Selected PR folder: $pr_dir"
        # Output JSON result
        echo '{"pr_dir":"'"$pr_dir"'"}'
    else
        log_error "No PR folders available"
        return 1
    fi
}
