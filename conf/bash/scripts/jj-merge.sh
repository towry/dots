#!/usr/bin/env bash

# use jj to merge two bookmarks, and advance one bookmark to the merge rev.
set -e

# Step 1: Argument parsing
MERGE_MESSAGE="[JJ]: Merge branch"
DELETE_MERGED_BRANCHES=false
PRINT_USAGE=false

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -m)
      if [ -z "$2" ]; then echo "Error: -m requires an argument" >&2; exit 1; fi
      MERGE_MESSAGE="$2"
      shift 2
      ;;
    --delete-merged)
      DELETE_MERGED_BRANCHES=true
      shift
      ;;
    -h|--help)
      PRINT_USAGE=true
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      PRINT_USAGE=true
      break
      ;;
    *)
      break # Stop processing options
      ;;
  esac
done

if [ "$PRINT_USAGE" = true ] || [ "$#" -lt 1 ]; then
  echo "Usage: $0 [-m \"message\"] [--delete-merged] <main-bookmark> [other-bookmarks...]"
  echo "  Merges 'other-bookmarks' into 'main-bookmark'."
  echo "  'main-bookmark' is fetched from remote 'origin' and then advanced to the new merge commit."
  echo ""
  echo "Options:"
  echo "  -m <message>        Use a custom merge commit message."
  echo "  --delete-merged     Delete 'other-bookmarks' after a successful merge."
  echo "  -h, --help          Show this help message."
  exit 1
fi

FIRST_BOOKMARK="$1"
shift # Remove the first argument
BOOKMARKS_TO_MERGE=("$@") # Store the rest of the bookmarks

# Step 2: Validate and execute jj git fetch for the specific bookmark
echo "Checking if bookmark '$FIRST_BOOKMARK' exists..."
if ! jj bookmark list | grep -q "^  ${FIRST_BOOKMARK}:"; then
  echo "Error: Bookmark '$FIRST_BOOKMARK' does not exist. Run 'jj bookmark list' to see available bookmarks."
  exit 1
fi

echo "Executing: jj git fetch origin \"$FIRST_BOOKMARK\""
FETCH_OUTPUT=$(jj git fetch origin "$FIRST_BOOKMARK" 2>&1)
FETCH_STATUS=$?

if [ $FETCH_STATUS -ne 0 ]; then
  # Check for non-zero exit code, but also for "not found" messages which jj treats as errors
  if echo "$FETCH_OUTPUT" | grep -qE "(not found|no such)"; then
    echo "Error: Remote branch for '$FIRST_BOOKMARK' not found on 'origin'."
  else
    echo "Error: 'jj git fetch origin \"$FIRST_BOOKMARK\"' failed."
  fi
  echo "Output from fetch command:"
  echo "$FETCH_OUTPUT"
  exit 1
fi

# Check if fetch was a no-op
if echo "$FETCH_OUTPUT" | grep -q -E "(Nothing changed|Already up-to-date)" || [ -z "$FETCH_OUTPUT" ]; then
    echo "Info: '$FIRST_BOOKMARK' is already up-to-date with remote 'origin'."
else
    echo "Success: Fetched updates for '$FIRST_BOOKMARK' from 'origin'."
    # Only show fetch output if it's not just a no-op message
    echo "$FETCH_OUTPUT"
fi

# Step 3: Create a new merge commit
# Step 3: Create a new merge commit
if [ ${#BOOKMARKS_TO_MERGE[@]} -eq 0 ]; then
  echo "No other bookmarks specified to merge. Nothing to do."
  exit 0
fi

echo "Checking out '$FIRST_BOOKMARK' to prepare for merge..."
if ! jj checkout "$FIRST_BOOKMARK"; then
  echo "Error: Failed to checkout '$FIRST_BOOKMARK'."
  exit 1
fi

echo "Executing: jj merge \"${BOOKMARKS_TO_MERGE[*]}\" -m \"$MERGE_MESSAGE\""
# No need for eval, shell handles the array expansion correctly.
MERGE_OUTPUT=$(jj merge "${BOOKMARKS_TO_MERGE[@]}" -m "$MERGE_MESSAGE" 2>&1)
MERGE_STATUS=$?


if [ $MERGE_STATUS -ne 0 ]; then
  echo "Error: '$MERGE_COMMAND' failed."
  echo "$MERGE_OUTPUT"
  exit 1
fi

# After a successful merge, '@' points to the new merge commit.
MERGE_REVISION=$(jj log -r @ --template "{commit_id}")
if [ -z "$MERGE_REVISION" ]; then
  echo "Error: Could not extract merge revision ID using 'jj log'."
  echo "Output from merge command:"
  echo "$MERGE_OUTPUT"
  exit 1
fi
echo "New merge revision created: $MERGE_REVISION"

# Step 4: Move the first bookmark to the new merge revision
echo "Moving bookmark '$FIRST_BOOKMARK' to the new merge revision..."
if ! jj bookmark set "$FIRST_BOOKMARK" -r "$MERGE_REVISION"; then
    echo "Error: 'jj bookmark set \"$FIRST_BOOKMARK\" -r \"$MERGE_REVISION\"' failed."
    exit 1
fi
# NOTE: Consider if the script should also delete the other bookmarks used in the merge, or if they should remain.

echo "Successfully merged bookmarks and moved '$FIRST_BOOKMARK' to revision '$MERGE_REVISION'."

if [ "$DELETE_MERGED_BRANCHES" = true ]; then
  echo "Cleaning up merged bookmarks..."
  for bookmark in "${BOOKMARKS_TO_MERGE[@]}"; do
    # Check if the item is a bookmark before attempting to delete it.
    # Revsets that are not bookmarks will be ignored.
    if jj bookmark list | grep -q "^  ${bookmark}:"; then
      echo "Deleting bookmark '$bookmark'..."
      if ! jj bookmark delete "$bookmark"; then
        echo "Warning: Failed to delete bookmark '$bookmark'."
      fi
    fi
  done
fi
