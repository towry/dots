#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""PostToolUse hook to mark handoff as handled after /pickup command.

When SlashCommand tool is used with /pickup, this hook:
1. Extracts the handoff filename from the command
2. Adds entry to .handled.json metadata file
"""

import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path


def mark_handoff_as_handled(project_dir: str, handoff_name: str) -> bool:
    """Mark a handoff file as handled via metadata file.

    Args:
        project_dir: Project root directory
        handoff_name: Name of the handoff file (just filename, not path)

    Returns:
        True if successfully marked, False otherwise
    """
    handoffs_dir = Path(project_dir) / ".claude" / "handoffs"
    metadata_file = handoffs_dir / ".handled.json"

    try:
        # Load existing metadata
        handled = {}
        if metadata_file.exists():
            handled = json.loads(metadata_file.read_text())

        # Add this handoff
        handled[handoff_name] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        # Write back
        metadata_file.write_text(json.dumps(handled, indent=2))
        return True

    except Exception as e:
        print(f"Failed to mark handoff as handled: {e}", file=sys.stderr)
        return False


def main():
    """Main hook entry point."""
    try:
        raw = sys.stdin.read()
        if not raw:
            sys.exit(0)
        input_data = json.loads(raw)
    except json.JSONDecodeError:
        sys.exit(0)

    # Check if this is a SlashCommand tool call
    tool_name = input_data.get("tool_name", "")
    if tool_name != "SlashCommand":
        sys.exit(0)

    # Get the command that was executed
    tool_input = input_data.get("tool_input", {})
    command = tool_input.get("command", "")

    # Check if it's a /pickup command
    if not command.startswith("/pickup"):
        sys.exit(0)

    # Extract handoff filename from command
    # Format: /pickup <filename> or /pickup filename.md
    match = re.match(r"/pickup\s+(.+)", command.strip())
    if not match:
        sys.exit(0)

    handoff_arg = match.group(1).strip()
    # Clean up - extract just the filename
    handoff_name = Path(handoff_arg).name

    if not handoff_name.endswith(".md"):
        handoff_name += ".md"

    # Get project directory
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR") or input_data.get("cwd", ".")

    # Mark handoff as handled
    if mark_handoff_as_handled(project_dir, handoff_name):
        print(f"Marked handoff as handled: {handoff_name}", file=sys.stderr)
    else:
        print(f"Could not mark handoff as handled: {handoff_name}", file=sys.stderr)

    sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        sys.exit(0)
