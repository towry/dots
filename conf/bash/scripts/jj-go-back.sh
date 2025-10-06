#!/usr/bin/env bash
# NOTE: Jump back to the commit that was active before the most recent `jj new`
# operation in the current repository.
set -euo pipefail

# Ensure pager never kicks in
export PAGER=cat

SCRIPT_NAME="jj-go-back"
SEARCH_LIMIT=200
VERBOSE=0
DRY_RUN=0
LIST_ALL=0

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]

Jump back to the commit that was active before the most recent 'jj new' operation.

OPTIONS:
  -a, --list-all      List all 'jj new' operations (does not perform jump)
  -n, --dry-run       Show what would be done without executing
  -v, --verbose       Show detailed operation information
  -l, --limit NUM     Search last NUM operations (default: $SEARCH_LIMIT)
  -h, --help          Show this help message

EXAMPLES:
  $SCRIPT_NAME              # Jump back to previous commit
  $SCRIPT_NAME -n           # Preview without executing
  $SCRIPT_NAME -v -l 500    # Verbose mode, search last 500 operations
  $SCRIPT_NAME -a           # List all recent 'jj new' operations
  $SCRIPT_NAME -a -l 50     # List 'jj new' operations from last 50 ops
EOF
  exit 0
}

err() {
  echo "[$SCRIPT_NAME] $1" >&2
  exit "${2:-1}"
}

log() {
  if [[ $VERBOSE -eq 1 ]]; then
    echo "[$SCRIPT_NAME] $1" >&2
  fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -a|--list-all)
      LIST_ALL=1
      shift
      ;;
    -n|--dry-run)
      DRY_RUN=1
      shift
      ;;
    -v|--verbose)
      VERBOSE=1
      shift
      ;;
    -l|--limit)
      if [[ -z "${2:-}" ]] || [[ "$2" =~ ^- ]]; then
        err "Option -l/--limit requires a numeric argument"
      fi
      SEARCH_LIMIT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      err "Unknown option: $1. Use -h for help."
      ;;
  esac
done

# Guard against running outside a jj repository
if ! jj root >/dev/null 2>&1; then
  err "Not inside a jj repository"
fi

# Handle list-all mode
if [[ $LIST_ALL -eq 1 ]]; then
  echo "[$SCRIPT_NAME] Listing 'jj new' operations from last $SEARCH_LIMIT operations:"
  echo ""
  LIST_TEMPLATE='if(self.tags().contains("jj new"), separate(" | ", self.time().start().format("%Y-%m-%d %H:%M:%S"), self.id().short(), self.description(), self.tags()) ++ "\n", "")'
  jj op log --no-graph --no-pager -n "$SEARCH_LIMIT" -T "$LIST_TEMPLATE" | grep . || echo "[$SCRIPT_NAME] No 'jj new' operations found in the last $SEARCH_LIMIT operations"
  exit 0
fi

# Find the most recent operation that ran `jj new`
log "Searching last $SEARCH_LIMIT operations for 'jj new' invocations..."

# Template format: <op_id> <parent_ids_comma_separated>
OP_TEMPLATE='if(self.tags().contains("jj new"), self.id().short() ++ " " ++ self.parents().map(|p| p.id().short()).join(",") ++ "\n", "")'
latest_op_line="$(jj op log --no-graph --no-pager -n "$SEARCH_LIMIT" -T "$OP_TEMPLATE" | grep -m 1 . || true)"

if [[ -z "$latest_op_line" ]]; then
  err "Unable to locate a recent \`jj new\` operation within the last $SEARCH_LIMIT operations"
fi

op_id="${latest_op_line%% *}"
parent_segment="${latest_op_line#* }"

log "Found operation: $op_id"

if [[ -z "$parent_segment" || "$parent_segment" == "$op_id" ]]; then
  err "The located operation ($op_id) has no parent information"
fi

# NOTE: Currently assuming the first parent is the base we want to return to.
parent_op_id="${parent_segment%%,*}"

if [[ -z "$parent_op_id" ]]; then
  err "Failed to extract parent operation id from: $parent_segment"
fi

log "Parent operation: $parent_op_id"

# Query the working copy commit that was current at the parent operation
log "Querying working copy commit at operation $parent_op_id..."
commit_template='commit_id ++ "\n"'
parent_commit="$(jj --at-op="$parent_op_id" log -r @ --no-graph --no-pager --limit 1 -T "$commit_template" | tr -d '\r')"

if [[ -z "$parent_commit" ]]; then
  err "Unable to determine the working copy commit at parent operation $parent_op_id"
fi

log "Target commit: $parent_commit"

# Short-circuit if we are already on the target commit
current_commit="$(jj log -r @ --no-graph --no-pager --limit 1 -T 'commit_id ++ "\n"' | tr -d '\r')"
log "Current commit: $current_commit"

if [[ "$current_commit" == "$parent_commit" ]]; then
  echo "[$SCRIPT_NAME] Already on target commit $parent_commit"
  echo "[$SCRIPT_NAME] (This was the commit before the most recent 'jj new' operation)"
  exit 0
fi

# Show operation details if verbose
if [[ $VERBOSE -eq 1 ]]; then
  op_info_template='separate(" | ", self.time().start().format("%Y-%m-%d %H:%M:%S"), self.description(), self.tags()) ++ "\n"'
  op_info="$(jj op log --no-graph --no-pager -n "$SEARCH_LIMIT" -T "if(self.id().short() == \"$op_id\", $op_info_template, \"\")" | head -n 1)"
  if [[ -n "$op_info" ]]; then
    log "Operation details: $op_info"
  fi
fi

if [[ $DRY_RUN -eq 1 ]]; then
  echo "[$SCRIPT_NAME] [DRY-RUN] Would execute: jj edit $parent_commit"
  echo "[$SCRIPT_NAME] [DRY-RUN] This would switch from commit $current_commit to $parent_commit"
  echo "[$SCRIPT_NAME] [DRY-RUN] Based on operation $op_id (parent: $parent_op_id)"
  exit 0
fi

echo "[$SCRIPT_NAME] Editing parent commit $parent_commit (operation $op_id -> parent $parent_op_id)"
exec jj edit "$parent_commit"
