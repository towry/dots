#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""UserPromptSubmit hook to enhance /pickup command with handoff directory context.

This hook:
1. Detects when user types "/pickup"
2. If a specific handoff file is provided, marks it as handled (moves to handled/)
3. Scans .claude/handoffs/ directory for available handoff files
4. Appends the list of available handoffs as context to the prompt
"""

import json
import os
import sys
from pathlib import Path
from datetime import datetime


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

        # Add this handoff with timestamp
        handled[handoff_name] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        # Write back
        metadata_file.write_text(json.dumps(handled, indent=2))
        return True
    except Exception as e:
        print(f"Failed to mark handoff as handled: {e}", file=sys.stderr)
        return False


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
        # Skip files in handled/ subdirectory
        if "handled" in filepath.parts:
            continue

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

    lines = [
        "Handoff files are manually created by user",
        f"**Available handoffs under `.claude/handoffs/`** ({len(handoffs)} files):",
        "",
    ]

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
        sys.exit(0)

    print("Detected /pickup command, processing...", file=sys.stderr)

    # Get project directory (prefer CLAUDE_PROJECT_DIR env var)
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR") or input_data.get("cwd", ".")

    # Extract handoff filename if provided (e.g., "/pickup my-handoff.md")
    parts = prompt.split(maxsplit=1)
    handoff_arg = parts[1].strip() if len(parts) > 1 else ""

    # If a specific handoff file is provided, mark it as handled
    if handoff_arg:
        # Clean up the argument - handle potential paths
        handoff_name = Path(handoff_arg).name
        if handoff_name.endswith(".md"):
            if mark_handoff_as_handled(project_dir, handoff_name):
                print(f"Marked handoff as handled: {handoff_name}", file=sys.stderr)
            else:
                print(
                    f"Could not mark handoff as handled: {handoff_name}",
                    file=sys.stderr,
                )

    # Scan handoffs directory for remaining handoffs
    handoffs = scan_handoffs_directory(project_dir)

    if not handoffs and not handoff_arg:
        # just exit
        sys.exit(0)

    # Format list of available handoffs
    context = format_handoffs_context(handoffs) if handoffs else ""

    # Print to stderr for debugging/logging purposes only
    if context:
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
