#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

"""Get last agent ID for session and inject into Claude as UserPromptSubmit context.

This reads the latest agent id file written by `subagent_remind.py` and prints
JSON `hookSpecificOutput` which will be injected into the parent user's context
for `UserPromptSubmit` hooks.

Optimized for efficiency: only reads from pre-written file, no transcript scanning.
The file is created by subagent_remind.py (SubagentStop hook) when a subagent completes.
"""

import json
import os
import sys
from pathlib import Path


def find_last_agent_file(project_dir: str, session_id: str) -> Path | None:
    """Find the last_agent_id file for this session."""
    if not session_id:
        return None
    try:
        p = Path(project_dir) / '.claude' / 'logs' / f'last_agent_id_{session_id}.txt'
        if p.exists():
            return p
    except Exception:
        pass
    return None


def main():
    """Main hook entry point - fast path only."""
    try:
        raw = sys.stdin.read()
        if not raw:
            sys.exit(0)

        try:
            input_data = json.loads(raw)
        except json.JSONDecodeError:
            sys.exit(0)

        session_id = input_data.get('session_id', '')
        if not session_id:
            sys.exit(0)

        project_dir = os.environ.get('CLAUDE_PROJECT_DIR') or input_data.get('cwd', '.')

        # Fast path: only check if file exists (created by subagent_remind.py)
        fpath = find_last_agent_file(project_dir, session_id)
        if not fpath:
            # No subagent was used in this session - exit quickly
            sys.exit(0)

        # Read agent ID from file
        try:
            agent_id = fpath.read_text().strip()
        except Exception:
            sys.exit(0)

        if not agent_id:
            sys.exit(0)

        # Inject context
        output_json = {
            'hookSpecificOutput': {
                'hookEventName': 'UserPromptSubmit',
                'additionalContext': f'Last subagent ID: {agent_id}'
            }
        }
        print(json.dumps(output_json))
        sys.exit(0)

    except Exception:
        sys.exit(0)


if __name__ == '__main__':
    main()
