#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "python-dotenv",
# ]
# ///

"""Hook: SessionStart reminder for Claude.

Reads JSON from stdin, extracts session_id and project directory,
logs the event to `.claude/logs/session_start.json`, and prints JSON
with hookSpecificOutput to inject a short reminder into Claude's context.

The script mirrors the style and error handling of `pre_compact.py`.
"""

import argparse
import json
import os
import sys
from pathlib import Path
from datetime import datetime

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass  # dotenv is optional


def log_session_start(input_data):
    """Log SessionStart event to `.claude/logs/session_start.json`.
    """
    log_dir = Path(".claude/logs")
    log_dir.mkdir(parents=True, exist_ok=True)
    log_file = log_dir / 'session_start.json'

    if log_file.exists():
        try:
            with open(log_file, 'r') as f:
                log_data = json.load(f)
        except (json.JSONDecodeError, ValueError):
            log_data = []
    else:
        log_data = []

    # Add a short metadata object: time, session_id, cwd
    entry = {
        'timestamp': datetime.now().isoformat(),
        'session_id': input_data.get('session_id'),
        'cwd': input_data.get('cwd'),
        'hook_event_name': input_data.get('hook_event_name'),
        'source': input_data.get('source') if 'source' in input_data else None,
    }
    log_data.append(entry)

    with open(log_file, 'w') as f:
        json.dump(log_data, f, indent=2)

    # Set restrictive permissions for privacy
    try:
        os.chmod(log_file, 0o600)
    except Exception:
        pass  # Best effort


def main():
    try:
        parser = argparse.ArgumentParser()
        parser.add_argument('--verbose', action='store_true', help='Print verbose output')
        args = parser.parse_args()

        # Read JSON input from stdin
        try:
            raw = sys.stdin.read()
            if not raw:
                # Nothing to do
                sys.exit(0)
            input_data = json.loads(raw)
        except json.JSONDecodeError:
            # Don't disrupt Claude if input is malformed
            sys.exit(0)

        # Extract fields
        session_id = input_data.get('session_id')
        if not session_id or not isinstance(session_id, str):
            # No valid session ID to inject
            sys.exit(0)

        # Sanitize session_id to prevent injection (remove newlines and control characters)
        session_id = ' '.join(session_id.strip().split())        # Prefer the CLAUDE_PROJECT_DIR env var (project-specific hooks set this), fall back to cwd
        project_dir = os.environ.get('CLAUDE_PROJECT_DIR') or input_data.get('cwd') or ''
        if project_dir and isinstance(project_dir, str):
            # Sanitize path - remove any embedded newlines or control characters
            project_dir = ' '.join(project_dir.strip().split())

        # Log the event for later debugging
        try:
            log_session_start(input_data)
        except Exception:
            # Best-effort logging only
            pass

        # Build the reminder message
        base_msg = f"✅ Session ID: {session_id}"
        if project_dir:
            base_msg += f"\n📁 Project directory: {project_dir}"

        # Optionally print debug info to stderr (not stdout) to avoid interfering with JSON output
        if args.verbose:
            verbose_msg = f"Session reminder injected. {session_id[:8]}... | Project: {project_dir}"
            print(verbose_msg, file=sys.stderr)

        # Emit the structured JSON for Claude to ingest
        output_json = {
            "hookSpecificOutput": {
                "hookEventName": "SessionStart",
                "additionalContext": base_msg,
            }
        }

        # Emit the structured JSON for Claude to ingest
        print(json.dumps(output_json))
        sys.exit(0)

    except Exception:
        # Fail gracefully without blocking the session
        sys.exit(0)


if __name__ == '__main__':
    main()
