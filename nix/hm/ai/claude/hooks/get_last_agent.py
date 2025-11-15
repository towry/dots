#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "python-dotenv",
# ]
# ///

"""Get last agent ID for session and inject into Claude as UserPromptSubmit context.

This reads the latest agent id file written by `subagent_remind.py` and prints
JSON `hookSpecificOutput` which will be injected into the parent user's context
for `UserPromptSubmit` hooks.
"""

import argparse
import json
import os
import sys
from pathlib import Path
from datetime import datetime
import re
import time

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass


def find_last_agent_file(project_dir: str, session_id: str) -> Path | None:
    try:
        p = Path(project_dir) / '.claude' / 'logs' / f'last_agent_id_{session_id}.txt'
        if p.exists():
            return p
        # Also consider possible session ID short form
        short = session_id.split('-')[0] if '-' in session_id else session_id
        p2 = Path(project_dir) / '.claude' / 'logs' / f'last_agent_id_{short}.txt'
        if p2.exists():
            return p2
    except Exception:
        pass
    return None


def extract_agent_id_from_obj(obj) -> str | None:
    """Recursively search a JSON-serializable object for explicit agentId fields.

    ONLY returns agentId from trusted locations to avoid false positives:
    - toolUseResult.agentId (primary and ONLY trusted source)

    Does NOT scan arbitrary strings or accept agentId from other locations
    to avoid matching UUIDs, session IDs, leafUuids, message UUIDs, etc.
    """
    try:
        if isinstance(obj, dict):
            # ONLY trust toolUseResult -> agentId (most reliable source)
            if 'toolUseResult' in obj and isinstance(obj['toolUseResult'], dict):
                agent = obj['toolUseResult'].get('agentId') or obj['toolUseResult'].get('agent_id')
                if isinstance(agent, str) and agent.strip():
                    agent = agent.strip()
                    # Agent IDs are typically 8 hex chars
                    if re.match(r'^[0-9a-fA-F]{8}$', agent):
                        return agent
            # Recurse into nested structures to find toolUseResult
            for k, v in obj.items():
                if isinstance(v, (dict, list)):
                    found = extract_agent_id_from_obj(v)
                    if found:
                        return found
        elif isinstance(obj, list):
            for v in obj:
                if isinstance(v, (dict, list)):
                    found = extract_agent_id_from_obj(v)
                    if found:
                        return found
        # DO NOT scan strings - too many false positives
        # DO NOT accept agentId from non-toolUseResult locations
    except Exception:
        pass
    return None
def search_transcript_for_agent_id(session_id: str, project_dir: str, debug: bool = False, retries: int = 10, delay_ms:int = 150) -> str | None:
    """Search the local claude transcript JSONL for an agent id relating to the given session id.

    This uses a small retry loop to allow the transcript to be flushed to disk if it's being written concurrently.
    Returns the most recent explicit tool agent id if found, else the most recent heuristic agent id.
    """
    try:
        logs_dir = Path.home() / '.claude' / 'projects'
        if not logs_dir.exists():
            return None
        # Candidate transcripts: files under ~/.claude/projects whose name contains the session id or directory contains the project dir name
        candidates = list(logs_dir.rglob(f'*{session_id}*.jsonl'))
        if not candidates:
            # Try broader search: any jsonl file under projects
            candidates = list(logs_dir.rglob('**/*.jsonl'))
        for attempt in range(retries):
            for trans in candidates:
                try:
                    last_found = None
                    last_tool_agent = None
                    with open(trans, 'r') as fh:
                        for line in fh:
                            line = line.strip()
                            if not line:
                                continue
                            try:
                                j = json.loads(line)
                            except Exception:
                                # Malformed JSON - skip this line entirely
                                # DO NOT try regex extraction on non-JSON lines
                                continue
                            # ONLY accept explicit toolUseResult.agentId
                            tool_agent = None
                            if isinstance(j, dict) and 'toolUseResult' in j and isinstance(j['toolUseResult'], dict):
                                tool_agent = j['toolUseResult'].get('agentId') or j['toolUseResult'].get('agent_id')
                            if tool_agent and isinstance(tool_agent, str) and tool_agent.strip():
                                # Validate it's 8 hex chars (agent ID format)
                                tool_agent = tool_agent.strip()
                                if re.match(r'^[0-9a-fA-F]{8}$', tool_agent):
                                    if debug:
                                        print(f'Found valid tool agent id {tool_agent} in transcript {trans}')
                                    last_tool_agent = tool_agent
                                elif debug:
                                    print(f'Rejected invalid tool agent id format: {tool_agent}')
                            # NO fallback to generic extraction - too risky
                    # after scanning file - ONLY return explicit tool agent IDs
                    if last_tool_agent:
                        # write a last_agent file for future use
                        try:
                            ldir = Path(project_dir) / '.claude' / 'logs'
                            ldir.mkdir(parents=True, exist_ok=True)
                            last_file = ldir / f'last_agent_id_{session_id}.txt'
                            last_file.write_text(last_tool_agent)
                            last_file.chmod(0o600)
                        except Exception:
                            pass
                        return last_tool_agent
                except Exception:
                    continue
            # If not found yet, wait and retry
            time.sleep(delay_ms / 1000.0)
        return None
    except Exception:
        return None


def main():
    try:
        parser = argparse.ArgumentParser()
        parser.add_argument('--quiet', action='store_true', default=False, help='Disable verbose output')
        parser.add_argument('--verbose', action='store_true', default=False, help='Enable verbose output (alias)')
        parser.add_argument('--debug', action='store_true', default=False, help='Write debug log to project .claude/logs')
        parser.add_argument('--no-debug', dest='debug', action='store_false', help='Disable debug logging')
        args = parser.parse_args()

        raw = sys.stdin.read()
        if not raw:
            # No input; nothing to do
            sys.exit(0)

        try:
            input_data = json.loads(raw)
        except Exception:
            # Malformed input
            sys.exit(0)

        session_id = str(input_data.get('session_id') or '')
        project_dir = os.environ.get('CLAUDE_PROJECT_DIR') or input_data.get('cwd') or '.'

        # Initialize agent_id early
        agent_id = None
        fpath = None

        if not session_id:
            # If the session id isn't provided, we'll try to fall back to the latest last_agent file
            # in the project logs. We don't fail early here to make the hook more robust for
            # prompt events where session metadata may be missing.
            if not args.quiet:
                print('No session id provided in hook input; attempting fallback behavior')

        # Try to find an existing last_agent file
        if session_id:
            fpath = find_last_agent_file(project_dir, session_id)

        # If the exact session file doesn't exist, look for the newest last_agent file
        if not fpath:
            try:
                logs_dir = Path(project_dir) / '.claude' / 'logs'
                if logs_dir.exists() and logs_dir.is_dir():
                    candidates = list(logs_dir.glob('last_agent_id_*.txt'))
                    if candidates:
                        # Pick the newest by mtime
                        candidates.sort(key=lambda p: p.stat().st_mtime, reverse=True)
                        fpath = candidates[0]
                        if not args.quiet and args.verbose:
                            print(f'Found fallback last_agent file: {fpath}')
                        # Write debug JSONL line
                        debug_enabled = args.debug or os.environ.get('CLAUDE_HOOK_DEBUG') == '1'
                        try:
                            if debug_enabled:
                                dbg_file = logs_dir / f'get_last_agent_debug_{session_id or "unknown"}.jsonl'
                                with open(dbg_file, 'a') as fh:
                                    fh.write(json.dumps({'timestamp': datetime.now().isoformat(), 'event': 'fallback_file', 'found_fpath': str(fpath)}) + '\n')
                        except Exception:
                            pass
            except Exception:
                pass

        # Try to read agent_id from file if we found one
        if fpath:
            try:
                agent_id = fpath.read_text().strip()
                if not agent_id:
                    # File exists but is empty - discard this path
                    fpath = None
            except Exception:
                # File read failed - discard this path
                fpath = None
                agent_id = None

        # If we still don't have an agent_id, try transcript search
        if not agent_id and session_id:
            if not args.quiet:
                print('No valid last agent file found; attempting transcript fallback')
            agent_id = search_transcript_for_agent_id(session_id, project_dir, args.debug)
            if args.debug:
                try:
                    logs_dir = Path(project_dir) / '.claude' / 'logs'
                    logs_dir.mkdir(parents=True, exist_ok=True)
                    dbg_file = logs_dir / f'get_last_agent_debug_{session_id}.jsonl'
                    with open(dbg_file, 'a') as fh:
                        fh.write(json.dumps({'timestamp': datetime.now().isoformat(), 'event': 'transcript_search', 'session_id': session_id, 'found_agent_id': agent_id}) + '\n')
                except Exception:
                    pass

        # Exit if no agent_id found through any method
        if not agent_id:
            if not args.quiet:
                print('No agent id found through file or transcript search')
            sys.exit(0)

        output_json = {
            'hookSpecificOutput': {
                'hookEventName': 'UserPromptSubmit',
                'additionalContext': f'✅ Last subagent ID for session {session_id or "unknown"}: {agent_id}'
            }
        }

        # Decide whether to print verbose messages. Default behavior is verbose unless --quiet.
        verbose = (not args.quiet) or args.verbose
        if verbose:
            source = f'file {fpath}' if fpath else 'transcript search'
            print(f'Found agent id: {agent_id} from {source}')

        print(json.dumps(output_json))
        sys.exit(0)
    except Exception:
        sys.exit(0)


if __name__ == '__main__':
    main()
