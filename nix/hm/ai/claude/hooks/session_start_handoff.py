#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""SessionStart hook to auto-detect pending handoffs and suggest pickup.

When a new session starts (startup or clear), this hook:
1. Scans .claude/handoffs/ for pending handoff files (not in handled/ subfolder)
2. If pending handoffs exist, prompts the agent to pick up the latest one
"""

import json
import os
import sys
from pathlib import Path
from datetime import datetime


def scan_pending_handoffs(project_dir: str) -> list[dict]:
    """Scan .claude/handoffs/ for pending (unhandled) handoff files.

    Args:
        project_dir: Project root directory

    Returns:
        List of pending handoff file info dicts
    """
    handoffs_dir = Path(project_dir) / ".claude" / "handoffs"

    if not handoffs_dir.exists():
        return []

    # Load handled handoffs from metadata file
    metadata_file = handoffs_dir / ".handled.json"
    handled_set = set()
    if metadata_file.exists():
        try:
            handled_data = json.loads(metadata_file.read_text())
            handled_set = set(handled_data.keys())
        except Exception:
            pass

    pending = []
    for filepath in sorted(
        handoffs_dir.glob("*.md"), key=lambda p: p.stat().st_mtime, reverse=True
    ):
        # Skip files in handled/ subdirectory (should not match anyway with glob)
        if "handled" in filepath.parts:
            continue

        # Skip files that are marked as handled in metadata
        if filepath.name in handled_set:
            continue

        stat = filepath.stat()
        pending.append(
            {
                "name": filepath.name,
                "path": str(filepath.relative_to(project_dir)),
                "modified": datetime.fromtimestamp(stat.st_mtime).strftime(
                    "%Y-%m-%d %H:%M:%S"
                ),
                "age_seconds": (
                    datetime.now() - datetime.fromtimestamp(stat.st_mtime)
                ).total_seconds(),
            }
        )

    return pending


def format_handoff_prompt(handoffs: list[dict]) -> str:
    """Format prompt for agent to pick up pending handoff.

    Args:
        handoffs: List of pending handoff files (sorted by most recent first)

    Returns:
        Formatted prompt string
    """
    if not handoffs:
        return ""

    latest = handoffs[0]

    # Build concise context message with clear action trigger
    lines = [
        "## AUTO-PICKUP TRIGGER",
        "",
        "When user sends single dot '.' or 'start' or 'go', you MUST immediately execute:",
        "```",
        f"/pickup {latest['name']}",
        "```",
        "Do NOT ask questions. Do NOT explain. Just run the SlashCommand tool with that command.",
        "",
        f"Pending handoff: `{latest['name']}`",
    ]

    if len(handoffs) > 1:
        lines.append(f"({len(handoffs) - 1} older handoff(s) also available)")

    return "\n".join(lines)


def main():
    """Main hook entry point."""
    try:
        raw = sys.stdin.read()
        if not raw:
            sys.exit(0)
        input_data = json.loads(raw)
    except json.JSONDecodeError:
        sys.exit(0)

    # Only trigger on clear (/clear or /new command)
    # Skip for startup/resume/compact which don't need handoff pickup
    source = input_data.get("source", "")
    if source != "clear":
        sys.exit(0)

    # Get project directory (prefer CLAUDE_PROJECT_DIR env var)
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR") or input_data.get("cwd", ".")

    # Scan for pending handoffs
    pending = scan_pending_handoffs(project_dir)

    if not pending:
        # No pending handoffs - exit silently
        sys.exit(0)

    # Format prompt for agent
    context = format_handoff_prompt(pending)

    latest = pending[0]

    # Create a visible system message that displays immediately
    system_msg = f"📋 Pending handoff detected: `{latest['name']}` (created: {latest['modified']})\nRun `/pickup {latest['name']}` to continue, or proceed with a new task."

    if len(pending) > 1:
        system_msg += f"\n({len(pending) - 1} older handoff(s) also available)"

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
        # If anything fails, exit silently to avoid breaking Claude
        sys.exit(0)
