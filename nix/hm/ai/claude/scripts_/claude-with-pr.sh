#!/usr/bin/env bash

# Claude with PR Context Script
#
# This script demonstrates the complete workflow:
# 1. Select a PR interactively
# 2. Generate system prompt with PR context
# 3. Start Claude with the system prompt configured
#
# Usage: ./claude-with-pr.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_BOOT_SCRIPT="$SCRIPT_DIR/claude-boot.sh"

# Colors with proper terminal detection
setup_colors() {
    if [[ -t 1 ]] && command -v tput &> /dev/null; then
        ncolors=$(tput colors 2>/dev/null || echo 0)
        if [[ $ncolors -ge 8 ]]; then
            RED='\033[0;31m'
            GREEN='\033[0;32m'
            YELLOW='\033[1;33m'
            BLUE='\033[0;34m'
            CYAN='\033[0;36m'
            BOLD='\033[1m'
            NC='\033[0m'
            COLORS_SUPPORTED=true
        fi
    fi

    # Fallback: no colors
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    BOLD=''
    NC=''
    COLORS_SUPPORTED=false
}

setup_colors

log_info() {
    if [[ "$COLORS_SUPPORTED" == "true" ]]; then
        echo -e "${BLUE}[INFO]${NC} $1"
    else
        echo "[INFO] $1"
    fi
}

log_success() {
    if [[ "$COLORS_SUPPORTED" == "true" ]]; then
        echo -e "${GREEN}[SUCCESS]${NC} $1"
    else
        echo "[SUCCESS] $1"
    fi
}

log_error() {
    if [[ "$COLORS_SUPPORTED" == "true" ]]; then
        echo -e "${RED}[ERROR]${NC} $1"
    else
        echo "[ERROR] $1"
    fi
}

show_usage() {
    if [[ "$COLORS_SUPPORTED" == "true" ]]; then
        cat << EOF
${CYAN}Claude with PR Context${NC}

This script provides a complete workflow for working with Claude AI using PR context.

${YELLOW}Workflow:${NC}
  1. Select a PR folder interactively
  2. Generate system prompt with PR context
  3. Start Claude with the configured system prompt

${YELLOW}Usage:${NC} $0 [OPTIONS]

${YELLOW}Options:${NC}
  --help, -h           Show this help message
  --dry-run            Generate system prompt but don't start Claude
  --export-prompt      Export system prompt to environment variable only

${YELLOW}Examples:${NC}
  $0                   # Full workflow: select PR, generate prompt, start Claude
  $0 --dry-run         # Show what system prompt would be generated
  $0 --export-prompt   # Export prompt to KIRO_SYSTEM_PROMPT env var

${YELLOW}Environment Variables:${NC}
  KIRO_SYSTEM_PROMPT   Will contain the generated system prompt

EOF
    else
        cat << 'EOF'
Claude with PR Context

This script provides a complete workflow for working with Claude AI using PR context.

Workflow:
  1. Select a PR folder interactively
  2. Generate system prompt with PR context
  3. Start Claude with the configured system prompt

Usage: ./claude-with-pr.sh [OPTIONS]

Options:
  --help, -h           Show this help message
  --dry-run            Generate system prompt but don't start Claude
  --export-prompt      Export system prompt to environment variable only

Examples:
  ./claude-with-pr.sh                # Full workflow
  ./claude-with-pr.sh --dry-run      # Show system prompt only
  ./claude-with-pr.sh --export-prompt # Export to env var

EOF
    fi
}

# Main workflow function
run_workflow() {
    local dry_run="${1:-false}"
    local export_only="${2:-false}"

    log_info "Starting Claude with PR context workflow..."

    # Step 1: Select PR interactively
    log_info "Step 1: Selecting PR folder..."
    local context_json
    context_json=$(echo "1" | "$CLAUDE_BOOT_SCRIPT" --pr-list 2>/dev/null)

    if [[ $? -ne 0 || -z "$context_json" ]]; then
        log_error "Failed to select PR folder"
        return 1
    fi

    local pr_dir
    pr_dir=$(echo "$context_json" | jq -r '.pr_dir // empty')

    if [[ -z "$pr_dir" ]]; then
        log_error "No PR directory selected"
        return 1
    fi

    log_success "Selected PR: $(basename "$pr_dir")"

    # Step 2: Generate system prompt
    log_info "Step 2: Generating system prompt..."
    local system_prompt
    system_prompt=$(echo "1" | "$CLAUDE_BOOT_SCRIPT" --pr-list --generate-prompt 2>/dev/null | grep -A 100 "Claude System Prompt")

    if [[ $? -ne 0 || -z "$system_prompt" ]]; then
        log_error "Failed to generate system prompt"
        return 1
    fi

    # Export system prompt to environment
    export KIRO_SYSTEM_PROMPT="$system_prompt"
    log_success "System prompt generated and exported to KIRO_SYSTEM_PROMPT"

    if [[ "$dry_run" == "true" ]]; then
        echo ""
        if [[ "$COLORS_SUPPORTED" == "true" ]]; then
            echo "${CYAN}=== Generated System Prompt ===${NC}"
        else
            echo "=== Generated System Prompt ==="
        fi
        echo "$system_prompt"
        echo ""
        log_info "Dry run completed. Claude was not started."
        return 0
    fi

    if [[ "$export_only" == "true" ]]; then
        log_info "System prompt exported to environment variable KIRO_SYSTEM_PROMPT"
        log_info "You can now start Claude manually with this prompt."
        return 0
    fi

    # Step 3: Start Claude with system prompt
    log_info "Step 3: Starting Claude with PR context..."
    echo ""

    if [[ "$COLORS_SUPPORTED" == "true" ]]; then
        echo "${CYAN}=== Starting Claude ===${NC}"
        echo "${GREEN}✓ PR Context: $pr_dir${NC}"
        echo "${GREEN}✓ System Prompt: Configured${NC}"
        echo ""
        echo "${YELLOW}Press Ctrl+C to exit Claude${NC}"
        echo ""
    else
        echo "=== Starting Claude ==="
        echo "✓ PR Context: $pr_dir"
        echo "✓ System Prompt: Configured"
        echo ""
        echo "Press Ctrl+C to exit Claude"
        echo ""
    fi

    # Start Claude with system prompt
    if command -v claude &> /dev/null; then
        # Try to feed system prompt to Claude
        echo "$system_prompt" | claude --system-prompt - 2>/dev/null || \
        echo "$system_prompt" | claude 2>/dev/null || \
        claude
    elif command -v aichat &> /dev/null; then
        # Fallback to aichat
        echo "$system_prompt" | aichat --role developer -S 2>/dev/null || \
        aichat --role developer -S
    else
        log_error "No Claude CLI found (claude or aichat)"
        log_info "System prompt is available in KIRO_SYSTEM_PROMPT environment variable"
        return 1
    fi
}

# Main script logic
main() {
    # Handle no arguments case
    if [[ $# -eq 0 ]]; then
        run_workflow
        return $?
    fi

    case "${1:-}" in
        --help|-h)
            show_usage
            ;;
        --dry-run)
            run_workflow "true" "false"
            ;;
        --export-prompt)
            run_workflow "false" "true"
            ;;
        *)
            log_error "Unknown option: ${1}"
            echo ""
            show_usage
            return 1
            ;;
    esac
}

# Ensure Kiro directory exists in project directory
KIRO_BASE_DIR="$(pwd)/llm/kiro"
if [[ ! -d "$KIRO_BASE_DIR" ]]; then
    mkdir -p "$KIRO_BASE_DIR"
    log_info "Created Kiro directory: $KIRO_BASE_DIR"
fi

# Check dependencies
if ! command -v jq &> /dev/null; then
    log_error "jq is required but not installed"
    exit 1
fi

if ! [[ -f "$CLAUDE_BOOT_SCRIPT" ]]; then
    log_error "claude-boot.sh script not found: $CLAUDE_BOOT_SCRIPT"
    exit 1
fi

# Run main function with all arguments
main "$@"