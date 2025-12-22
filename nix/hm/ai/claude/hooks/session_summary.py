#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""SessionStart hook to inject previous session summary as context.

When starting a new session (/new or /clear), this hook:
1. Reads the summary saved by the SessionEnd hook
2. Injects it as additional context for the new session
"""

import json
import sys
from pathlib import Path


def read_previous_summary(cwd: str) -> str:
    """Read the most recent summary from the session-summary directory.

    NOTE: This function is paired with `session_save.py` which writes these files
    on SessionEnd. If you change the directory path or glob pattern here,
    you MUST update `save_summary()` in session_save.py to match.

    Current contract:
        - Directory: .claude/session-summary/
        - Pattern: {timestamp}-summary-ID_{session_id}.md

    Args:
        cwd: Project directory

    Returns:
        Summary text, or empty string if not found
    """
    summary_dir = Path(cwd) / ".claude" / "session-summary"

    if not summary_dir.exists():
        return ""

    # Find all summary files, sorted by name (timestamp) descending
    summary_files = sorted(
        summary_dir.glob("*-summary-ID_*.md"),
        key=lambda p: p.name,
        reverse=True,
    )

    if not summary_files:
        return ""

    try:
        with open(summary_files[0], "r") as f:
            return f.read().strip()
    except Exception:
        return ""


def main():
    """Main hook entry point."""
    try:
        raw = sys.stdin.read()
        if not raw:
            sys.exit(0)
        input_data = json.loads(raw)
    except json.JSONDecodeError:
        sys.exit(0)

    # Only trigger on clear (/new or /clear command)
    source = input_data.get("source", "")
    if source != "clear":
        sys.exit(0)

    cwd = input_data.get("cwd", ".")

    # Read the summary saved by SessionEnd hook
    summary = read_previous_summary(cwd)

    if not summary:
        # No summary available - exit silently
        sys.exit(0)

    # Return as additional context for new session
    context = f"""<last-session>

{summary}</last-session>"""

    # Create a visible system message
    system_msg = f"History context loaded"

    output = {
        "systemMessage": system_msg,
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": context,
        },
    }

    print(json.dumps(output))
    sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        # Exit silently on any error to avoid breaking Claude
        sys.exit(0)
