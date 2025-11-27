#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

"""PreCompact hook - logs compaction events to JSONL file.

Triggered before Claude compacts the conversation context.
Logs are appended to .claude/logs/pre_compact.jsonl for debugging.
"""

import json
import os
import sys
from pathlib import Path
from datetime import datetime


def log_pre_compact(input_data: dict, project_dir: str) -> None:
    """Append pre-compact event to JSONL log (efficient append-only)."""
    try:
        log_dir = Path(project_dir) / ".claude" / "logs"
        log_dir.mkdir(parents=True, exist_ok=True)
        log_file = log_dir / "pre_compact.jsonl"

        # Add timestamp to the log entry
        entry = {
            "timestamp": datetime.now().isoformat(),
            "session_id": input_data.get("session_id", ""),
            "trigger": input_data.get("trigger", ""),
        }

        # Append single line (JSONL format - no need to read/rewrite entire file)
        with open(log_file, "a") as f:
            f.write(json.dumps(entry) + "\n")
    except Exception:
        pass  # Don't fail the hook if logging fails


def main():
    """Main hook entry point."""
    try:
        raw = sys.stdin.read()
        if not raw:
            sys.exit(0)

        input_data = json.loads(raw)
        project_dir = os.environ.get("CLAUDE_PROJECT_DIR") or input_data.get("cwd", ".")

        # Log the pre-compact event
        log_pre_compact(input_data, project_dir)

        # Success - compaction will proceed
        sys.exit(0)

    except Exception:
        sys.exit(0)


if __name__ == "__main__":
    main()
