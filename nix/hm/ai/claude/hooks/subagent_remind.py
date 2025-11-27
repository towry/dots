#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

"""Hook: SubagentStop - extracts agent ID and writes to file for resume workflows.

When a subagent (Task tool) completes, this hook:
1. Extracts the agent ID from the hook input
2. Writes it to .claude/logs/last_agent_id_{session_id}.txt
3. Injects the agent ID into context for visibility

The file is read by get_last_agent.py (UserPromptSubmit hook) to show
the last agent ID, useful for resuming agents via Task tool.
"""

import json
import os
import re
import sys
from pathlib import Path


def extract_agent_id(input_data: dict) -> str | None:
    """Extract agent ID from hook input.

    Only accepts 8-character hex agent IDs to avoid false positives.
    """
    def validate(val):
        if isinstance(val, str) and re.match(r'^[0-9a-fA-F]{8}$', val.strip()):
            return val.strip()
        return None

    # Check top-level keys
    for key in ('agentId', 'agent_id'):
        if key in input_data:
            if v := validate(input_data[key]):
                return v

    # Check toolUseResult (most reliable source)
    tool_result = input_data.get('toolUseResult') or input_data.get('tool_use_result')
    if isinstance(tool_result, dict):
        for key in ('agentId', 'agent_id'):
            if key in tool_result:
                if v := validate(tool_result[key]):
                    return v

    return None


def main():
    """Main hook entry point."""
    try:
        raw = sys.stdin.read()
        if not raw:
            sys.exit(0)

        try:
            input_data = json.loads(raw)
        except json.JSONDecodeError:
            sys.exit(0)

        # Extract agent ID from input
        agent_id = extract_agent_id(input_data)
        if not agent_id:
            sys.exit(0)

        session_id = input_data.get('session_id', '')
        project_dir = os.environ.get('CLAUDE_PROJECT_DIR') or input_data.get('cwd', '.')

        # Write agent ID to file for get_last_agent.py to read
        if session_id:
            try:
                target_dir = Path(project_dir) / '.claude' / 'logs'
                target_dir.mkdir(parents=True, exist_ok=True)
                file_path = target_dir / f'last_agent_id_{session_id}.txt'
                file_path.write_text(agent_id)
                file_path.chmod(0o600)
            except Exception:
                pass

        # Inject agent ID into context
        output = {
            "hookSpecificOutput": {
                "hookEventName": "SubagentStop",
                "additionalContext": f"Subagent completed. ID: {agent_id}",
            }
        }
        print(json.dumps(output))
        sys.exit(0)

    except Exception:
        sys.exit(0)


if __name__ == "__main__":
    main()
