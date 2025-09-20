#!/usr/bin/env bash
set -euo pipefail

# Get the bash scripts directory
bashScriptsDir="$HOME/.local/bash/scripts"

# Parse arguments
extra_context=""
rev=""
debug_mode=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -m)
      shift
      if [[ $# -eq 0 ]]; then
        echo "[AI-CI] ERROR: -m flag requires a message argument" >&2
        exit 1
      fi
      extra_context="$1"
      [[ "$debug_mode" == true ]] && echo "[AI-CI] Extra context provided: $extra_context"
      ;;
    --debug)
      debug_mode=true
      echo "[AI-CI] Debug mode enabled"
      ;;
    *)
      if [[ -z "$rev" ]]; then
        rev="$1"
      else
        echo "[AI-CI] ERROR: Unexpected argument: $1" >&2
        echo "Usage: jj ai-ci [--debug] [-m <extra_context>] [revision]" >&2
        exit 1
      fi
      ;;
  esac
  shift
done

# Helper function for debug logging
debug_log() {
  if [[ "$debug_mode" == true ]]; then
    echo "$1"
  fi
}

if [[ -z "$rev" ]]; then
  # No revision provided - create interactive commit first
  debug_log "[AI-CI] Step 1/4: No revision provided. Creating interactive commit..."

  # Check if we have a proper TTY for interactive mode
  if [[ ! -t 0 ]] || [[ ! -t 1 ]]; then
    echo "[AI-CI] ERROR: No TTY available for interactive commit. Please run from terminal or provide revision ID." >&2
    echo "Usage: $0 [--debug] [-m <extra_context>] [revision]" >&2
    exit 1
  fi

  # Run interactive commit (let it be truly interactive)
  if ! jj commit -m 'WIP: empty message' --color=never --no-pager -i; then
    exit_code=$?
    echo "[AI-CI] ERROR: Interactive commit failed or was cancelled (exit code: $exit_code)" >&2
    exit $exit_code
  fi
  debug_log "[AI-CI] Step 1/4: ✓ Interactive commit successful"

  debug_log "[AI-CI] Step 2/4: Extracting parent commit ID..."
  # Now get the status output to extract parent commit ID
  output=$(jj status --color=never --no-pager 2>&1)

  # Extract the parent commit ID from the output
  # Looking for pattern like: "Parent commit (@-): pknnznu 1c577a2 (empty) WIP: empty message"
  rev=$(echo "$output" | grep -E "Parent commit.*:" | sed -E 's/Parent commit \(@-\): ([a-z0-9]+) .*/\1/')

  if [[ -z "$rev" ]]; then
    echo "[AI-CI] ERROR: Could not extract parent commit ID from jj output" >&2
    echo "Output was: $output" >&2
    exit 1
  fi

  debug_log "[AI-CI] Step 2/4: ✓ Using rev: $rev"
else
  # Revision provided as argument
  debug_log "[AI-CI] ✓ Using provided revision: $rev"
fi

debug_log "[AI-CI] Step 3/4: Generating commit context..."
# Generate commit context and check if successful
if ! context_output=$("$bashScriptsDir/jj-commit-context.sh" "$rev" 2>&1); then
  echo "[AI-CI] ERROR: Failed to generate commit context:" >&2
  echo "$context_output" >&2
  exit 1
fi
debug_log "[AI-CI] Step 3/4: ✓ Commit context generated successfully"
debug_log "[AI-CI] Context output length: ${#context_output}"

debug_log "[AI-CI] Step 4/4: Generating AI commit message and applying..."

# Prepare input for aichat - combine context with extra context if provided
ai_input="$context_output"
if [[ -n "$extra_context" ]]; then
  ai_input=$(printf "%s\n\nAdditional context: %s" "$context_output" "$extra_context")
  debug_log "[AI-CI] Including extra context in AI generation"
fi

# Generate commit message using aichat with jj context and apply it
if ! ai_output=$(echo "$ai_input" | aichat --role git-commit -S -c 2>&1); then
  aichat_exit_code=$?
  echo "[AI-CI] ERROR: Failed to generate AI commit message (exit code: $aichat_exit_code)" >&2
  echo "aichat output: $ai_output" >&2
  exit $aichat_exit_code
fi
debug_log "[AI-CI] Step 4/4: ✓ AI commit message generated"

debug_log "[AI-CI] Applying commit message..."
if ! echo "$ai_output" | "$bashScriptsDir/jj-ai-commit.sh" "$rev"; then
  apply_exit_code=$?
  echo "[AI-CI] ERROR: Failed to apply commit message (exit code: $apply_exit_code)" >&2
  echo "AI message was: $ai_output" >&2
  exit $apply_exit_code
fi
debug_log "[AI-CI] ✓ Commit message applied successfully"
echo "[AI-CI] ✓ AI commit process completed successfully!"
