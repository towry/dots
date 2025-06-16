#!/usr/bin/env bash

# Wrapper script for ai-commit that properly handles pipeline failures
# This ensures that if any step in the pipeline fails, the entire process stops

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define the pipeline components
CONTEXT_SCRIPT="${SCRIPT_DIR}/git-commit-context.sh"
CHUNK_SCRIPT="${SCRIPT_DIR}/git-commit-chunk-text.sh"

# First, run the context script and capture its output
# If it fails, the script will exit here due to set -e
context_output=$("$CONTEXT_SCRIPT")

# If we get here, the context script succeeded, so continue with the pipeline
echo "$context_output" | aichat --role git-commit -S | "$CHUNK_SCRIPT"
