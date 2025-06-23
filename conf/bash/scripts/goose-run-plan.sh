#!/usr/bin/env bash

# Script to run Goose with a specified plan file
# Usage: goose-run-plan.sh <plan-file.md>

set -euo pipefail

# Check if plan file is provided
if [ "$#" -eq 0 ]; then
    echo "Error: No plan file specified"
    echo "Usage: $0 <plan-file.md>"
    exit 1
fi

PLAN_FILE="$1"

# Verify plan file exists
if [ ! -f "$PLAN_FILE" ]; then
    echo "Error: Plan file '$PLAN_FILE' not found"
    exit 1
fi

# Check if file has .md extension
if [[ "$PLAN_FILE" != *.md ]]; then
    echo "Warning: Plan file should have .md extension"
fi

# Run Goose with the plan file
echo "Running Goose with plan file: $PLAN_FILE"
goose run -s -i "$PLAN_FILE"