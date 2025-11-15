#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "python-dotenv",
# ]
# ///

"""Hook: SubagentStop reminder for Claude.

Reads JSON from stdin, extracts agent ID from common locations in the
hook input, logs the event to `.claude/logs/subagent_stop.json`, and
prints JSON with hookSpecificOutput so the agent ID is visible in
context (useful to resume agents via Task tool resume parameter).
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


def log_subagent_stop(input_data):
    """Log SubagentStop events to `.claude/logs/subagent_stop.json`.
    """
    log_dir = Path(".claude/logs")
    log_dir.mkdir(parents=True, exist_ok=True)
    log_file = log_dir / 'subagent_stop.json'

    if log_file.exists():
        try:
            with open(log_file, 'r') as f:
                log_data = json.load(f)
        except (json.JSONDecodeError, ValueError):
            log_data = []
    else:
        log_data = []

    # Include a short metadata object so the logs aren't large
    entry = {
        'timestamp': datetime.now().isoformat(),
        'session_id': input_data.get('session_id'),
        'hook_event_name': input_data.get('hook_event_name'),
        'cwd': input_data.get('cwd'),
    }
    # Keep a copy of the minimal tool result if present
    tool_use = input_data.get('toolUseResult') or input_data.get('tool_use_result')
    if tool_use:
        entry['tool_use_result'] = {
            'agentId': tool_use.get('agentId') or tool_use.get('agent_id')
        }

    log_data.append(entry)

    with open(log_file, 'w') as f:
        json.dump(log_data, f, indent=2)


def extract_agent_id(input_data):
    """Try to extract agent id from different possible fields in hook input.

    Only accepts 8-character hex agent IDs to avoid false positives.
    Returns the agent id string or None if not found.
    """
    import re

    def validate_agent_id(val):
        """Validate that a value looks like an agent ID (8 hex chars)."""
        if not isinstance(val, str):
            return None
        val = val.strip()
        # Agent IDs are 8 hex characters, not full UUIDs or other formats
        if re.match(r'^[0-9a-fA-F]{8}$', val):
            return val
        return None

    # Common locations based on conversation log formats and the Skill doc
    # 1) top-level keys
    for key in ('agentId', 'agent_id', 'agentIdValue'):
        if key in input_data and input_data[key]:
            validated = validate_agent_id(input_data[key])
            if validated:
                return validated

    # 2) toolUseResult or tool_use_result (most reliable)
    tool_result = input_data.get('toolUseResult') or input_data.get('tool_use_result')
    if tool_result:
        for k in ('agentId', 'agent_id'):
            if k in tool_result and tool_result[k]:
                validated = validate_agent_id(tool_result[k])
                if validated:
                    return validated

    # 3) nested inside tool_response or toolResponse
    tool_response = input_data.get('tool_response') or input_data.get('toolResponse')
    if tool_response and isinstance(tool_response, dict):
        # If tool_response contains `toolUseResult` itself
        inner = tool_response.get('toolUseResult') or tool_response.get('tool_use_result')
        if inner:
            for k in ('agentId', 'agent_id'):
                if k in inner and inner[k]:
                    validated = validate_agent_id(inner[k])
                    if validated:
                        return validated

    return None


def extract_agent_id_from_transcript(transcript_path: str) -> str | None:
    """Read a transcript JSONL file and find the most recent agentId in toolUseResult entries.

    Returns the last agentId found or None if none present or file unreadable.
    """
    if not transcript_path:
        return None

    try:
        p = Path(transcript_path)
        if not p.exists() or not p.is_file():
            return None

        last_agent = None
        with open(p, 'r') as f:
            for line in f:
                try:
                    obj = json.loads(line)
                except Exception:
                    continue
                # Use the existing extraction logic for nested objects
                maybe = extract_agent_id(obj)
                if maybe:
                    last_agent = maybe
        return last_agent
    except Exception:
        return None


def main():
    try:
        parser = argparse.ArgumentParser()
        parser.add_argument('--verbose', action='store_true', help='Print verbose output')
        parser.add_argument('--debug', action='store_true', default=False, help='Write debug log to project .claude/logs')
        parser.add_argument('--no-debug', dest='debug', action='store_false', help='Disable debug logging')
        args = parser.parse_args()

        raw = sys.stdin.read()
        if not raw:
            sys.exit(0)

        try:
            input_data = json.loads(raw)
        except json.JSONDecodeError:
            sys.exit(0)

        # establish session id early so debug logs can reference it
        session_id = str(input_data.get('session_id') or 'unknown')

        # Log the event (best-effort)
        try:
            log_subagent_stop(input_data)
        except Exception:
            pass

        debug_enabled = args.debug or os.environ.get('CLAUDE_HOOK_DEBUG') == '1'
        if args.verbose:
            print('SubagentStop hook input keys:', list(input_data.keys()))
            print('Provided transcript_path:', input_data.get('transcript_path') or input_data.get('transcriptPath') or os.environ.get('CLAUDE_TRANSCRIPT_PATH'))

        agent_id = extract_agent_id(input_data)
        if args.verbose:
            print('Agent id from input_data:', agent_id)

        if not agent_id:
            # Nothing to echo - do not block or raise
            # Try transcript_path fallback
            transcript_path = input_data.get('transcript_path') or input_data.get('transcriptPath') or os.environ.get('CLAUDE_TRANSCRIPT_PATH')
            if transcript_path:
                # It's possible the transcript hasn't yet been updated when the hook runs.
                # Try a small retry loop to handle race conditions where the agent id appears shortly after the SubagentStop event.
                retries = 10
                delay = 0.15
                for attempt in range(retries):
                    agent_id = extract_agent_id_from_transcript(transcript_path)
                    if agent_id:
                        break
                    if args.verbose:
                        print(f'Attempt {attempt+1}/{retries}: agent id not found yet in transcript, sleeping {delay}s')
                    try:
                        import time
                        time.sleep(delay)
                    except Exception:
                        pass

            if args.verbose:
                print('Agent id from transcript after retry:', agent_id)
            # Write a debug log entry for the transcript extraction result
            if debug_enabled:
                try:
                    proj_dir = os.environ.get('CLAUDE_PROJECT_DIR') or input_data.get('cwd') or '.'
                    dbg_dir = Path(proj_dir) / '.claude' / 'logs'
                    dbg_dir.mkdir(parents=True, exist_ok=True)
                    dbg_file = dbg_dir / f'subagent_remind_debug_{session_id}.jsonl'
                    with open(dbg_file, 'a') as fh:
                        fh.write(json.dumps({
                            'timestamp': datetime.now().isoformat(),
                            'event': 'transcript_extract_result',
                            'session_id': session_id,
                            'transcript_path': transcript_path,
                            'found_agent_id': agent_id,
                            'attempts': retries
                        }) + '\n')
                except Exception:
                    pass
            if not agent_id:
                if args.verbose:
                    print('No agent_id found in SubagentStop input or transcript')
                sys.exit(0)

        # Build the reminder message
        base_msg = f"✅ Subagent ID: {agent_id}"

        # Print optional verbose message
        if args.verbose:
            print(f"SubagentStop: agent id {agent_id} detected")

        output_json = {
            "hookSpecificOutput": {
                "hookEventName": "SubagentStop",
                "additionalContext": base_msg,
            }
        }

        print(json.dumps(output_json))

        # Also write the agent id to a file for parent resume workflows
        # Use CLAUDE_PROJECT_DIR when available, fall back to cwd from hook input
        try:
            session_id = str(input_data.get('session_id') or 'unknown')
            project_dir = os.environ.get('CLAUDE_PROJECT_DIR') or input_data.get('cwd') or '.'
            target_dir = Path(project_dir) / '.claude' / 'logs'
            target_dir.mkdir(parents=True, exist_ok=True)
            file_path = target_dir / f'last_agent_id_{session_id}.txt'
            # Write the agent id and set file permissions to owner-only
            if args.verbose:
                print(f'About to write agent id: {agent_id} to {file_path}')
            if debug_enabled:
                try:
                    dbg_file2 = target_dir / f'subagent_remind_debug_{session_id}.jsonl'
                    with open(dbg_file2, 'a') as fh:
                        fh.write(json.dumps({
                            'timestamp': datetime.now().isoformat(),
                            'event': 'about_to_write',
                            'session_id': session_id,
                            'agent_id': agent_id,
                            'file_path': str(file_path)
                        }) + '\n')
                except Exception:
                    pass
            with open(file_path, 'w') as hf:
                hf.write(str(agent_id))
            try:
                os.chmod(file_path, 0o600)
            except Exception:
                # Ignore permission API errors on non-UNIX or where chown unavailable
                pass
            if args.verbose:
                print(f'Wrote agent id to {file_path}')
            if debug_enabled:
                try:
                    dbg_file3 = target_dir / f'subagent_remind_debug_{session_id}.jsonl'
                    with open(dbg_file3, 'a') as fh:
                        fh.write(json.dumps({
                            'timestamp': datetime.now().isoformat(),
                            'event': 'wrote_file',
                            'session_id': session_id,
                            'agent_id': agent_id,
                            'file_path': str(file_path)
                        }) + '\n')
                except Exception:
                    pass
        except Exception:
            # Best-effort; don't fail the hook if this write fails
            pass
        sys.exit(0)
    except Exception:
        sys.exit(0)


if __name__ == '__main__':
    main()
