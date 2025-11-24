#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""UserPromptSubmit hook to enhance /pickup command with handoff directory context.

This hook:
1. Detects when user types "/pickup"
2. Scans .claude/handoffs/ directory for available handoff files
3. Appends the list of available handoffs as context to the prompt
4. Allows the command to proceed with enhanced context
"""

import json
import sys
from pathlib import Path
from datetime import datetime


def scan_handoffs_directory(project_dir: str) -> list[dict]:
    """Scan .claude/handoffs/ directory for handoff files.

    Args:
        project_dir: Project root directory

    Returns:
        List of handoff file info dicts with 'name', 'path', 'modified', 'size'
    """
    handoffs_dir = Path(project_dir) / ".claude" / "handoffs"

    if not handoffs_dir.exists():
        return []

    handoffs = []
    for filepath in sorted(
        handoffs_dir.glob("*.md"), key=lambda p: p.stat().st_mtime, reverse=True
    ):
        stat = filepath.stat()
        handoffs.append(
            {
                "name": filepath.name,
                "path": str(filepath.relative_to(project_dir)),
                "modified": datetime.fromtimestamp(stat.st_mtime).strftime(
                    "%Y-%m-%d %H:%M:%S"
                ),
            }
        )

    return handoffs


def format_handoffs_context(handoffs: list[dict]) -> str:
    """Format handoffs list as helpful context.

    Args:
        handoffs: List of handoff file info

    Returns:
        Formatted context string
    """
    if not handoffs:
        return "No handoffs found in `.claude/handoffs/`"

    lines = [f"**Available handoffs under `.claude/handoffs/`** ({len(handoffs)} files):", ""]

    for i, handoff in enumerate(handoffs, 1):
        lines.append(f"{i}. `{handoff['name']}` — {handoff['modified']}")

    return "\n".join(lines)


def main():
    """Main hook entry point."""
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(1)

    prompt = input_data.get("prompt", "").strip()

    # Check if this is a /pickup command
    if not prompt.startswith("/pickup"):
        # Not a pickup command, allow it to proceed normally
        output = {"hookSpecificOutput": {"hookEventName": "UserPromptSubmit"}}
        print(json.dumps(output))
        sys.exit(0)
    
    print("Detected /pickup command, listing handoffs...", file=sys.stderr)

    # Get project directory
    project_dir = input_data.get("cwd", ".")

    # Scan handoffs directory
    handoffs = scan_handoffs_directory(project_dir)

    if not handoffs:
        # No handoffs found
        output = {
            "hookSpecificOutput": {
                "hookEventName": "UserPromptSubmit",
                "additionalContext": "No handoff files found in `.claude/handoffs/`",
            }
        }
        print(json.dumps(output))
        sys.exit(0)

    # Format list of available handoffs
    context = format_handoffs_context(handoffs)
    
    # Print to stderr for debugging/logging purposes only
    print(context, file=sys.stderr)

    # Return JSON output with additional context
    output = {
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": context,
        }
    }

    print(json.dumps(output))
    sys.exit(0)


if __name__ == "__main__":
    main()
