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
import subprocess
import sys
from pathlib import Path
from datetime import datetime


# Constants
LOG_DIR = Path(".claude/logs")
LOG_FILE = LOG_DIR / "session_start.json"
DATE_FORMAT = "%Y-%m-%d"


def load_log_data(log_file):
    """Load existing log data or return empty list."""
    if log_file.exists():
        try:
            with open(log_file, "r") as f:
                return json.load(f)
        except (json.JSONDecodeError, ValueError):
            pass
    return []


def save_log_data(log_file, log_data):
    """Save log data and set restrictive permissions."""
    log_file.parent.mkdir(parents=True, exist_ok=True)
    with open(log_file, "w") as f:
        json.dump(log_data, f, indent=2)
    try:
        os.chmod(log_file, 0o600)
    except Exception:
        pass  # Best effort


def log_session_start(input_data):
    """Log SessionStart event to log file."""
    log_data = load_log_data(LOG_FILE)
    entry = {
        "timestamp": datetime.now().isoformat(),
        "session_id": input_data.get("session_id"),
        "cwd": input_data.get("cwd"),
        "hook_event_name": input_data.get("hook_event_name"),
        "source": input_data.get("source"),
    }
    log_data.append(entry)
    save_log_data(LOG_FILE, log_data)


def sanitize_string(value):
    """Remove newlines and control characters from string."""
    if not isinstance(value, str):
        return ""
    return " ".join(value.strip().split())


def detect_repo_type(project_dir):
    """Detect repository type (jj, git, or no-repo) using repo_check.sh.

    Returns tuple of (repo_type, reminder_msg or None).
    """
    if not project_dir:
        return None, None

    script_path = Path.home() / ".claude/skills/git-jj/scripts/repo_check.sh"
    if not script_path.exists():
        return None, None

    try:
        result = subprocess.run(
            ["bash", str(script_path)],
            capture_output=True,
            text=True,
            timeout=5,
            cwd=project_dir,
        )
        repo_type = result.stdout.strip()

        if repo_type == "jj":
            return "jj", "Load git-jj skill when using git/vcs commands."
        elif repo_type == "git":
            return "git", None
        else:
            return None, None
    except Exception:
        return None, None


def build_reminder_message(session_id, project_dir):
    """Build the session reminder message with datetime."""
    today = datetime.now().strftime(DATE_FORMAT)
    msg = "Shell: fish, tools: rg, git, jj, fd, ast-greap, bun, exa \n"
    msg += f"Session ID: {session_id}\n"
    msg += f"Today is: {today}\n"
    if project_dir:
        msg += f"Current project root: {project_dir}"

    # Add repository type info
    repo_type, repo_reminder = detect_repo_type(project_dir)
    if repo_type:
        msg += f"\nRepo type: {repo_type}"
        if repo_reminder:
            msg += f"\nNote: {repo_reminder}"

    # Add kiro directory if present
    kiro_dir = os.environ.get("KIRO_DIR", "").strip()
    if kiro_dir:
        msg += f"\nKiro spec dir: {kiro_dir}"
    return msg


def read_input_data():
    """Read and parse JSON from stdin. Returns None if invalid."""
    try:
        raw = sys.stdin.read()
        return json.loads(raw) if raw else None
    except json.JSONDecodeError:
        return None


def main():
    try:
        parser = argparse.ArgumentParser()
        parser.add_argument(
            "--verbose", action="store_true", help="Print verbose output"
        )
        args = parser.parse_args()

        # Read JSON input
        input_data = read_input_data()
        if not input_data:
            sys.exit(0)

        # Extract and validate session_id
        session_id = input_data.get("session_id")
        if not session_id or not isinstance(session_id, str):
            sys.exit(0)

        # Sanitize inputs
        session_id = sanitize_string(session_id)
        project_dir = sanitize_string(
            os.environ.get("CLAUDE_PROJECT_DIR") or input_data.get("cwd") or ""
        )

        # Log event (best-effort)
        try:
            log_session_start(input_data)
        except Exception:
            pass

        # Build and emit reminder
        reminder_msg = build_reminder_message(session_id, project_dir)

        if args.verbose:
            print(
                f"Session reminder injected. {session_id[:8]}... | Project: {project_dir}",
                file=sys.stderr,
            )

        # Get kiro dir name (basename only) for system message
        kiro_dir = os.environ.get("KIRO_DIR", "").strip()
        kiro_name = Path(kiro_dir).name if kiro_dir else ""
        system_msg = f"Remind - Project: {project_dir}"
        if kiro_name:
            system_msg += f", Kiro: {kiro_name}"

        output_json = {
            "systemMessage": system_msg,
            "hookSpecificOutput": {
                "hookEventName": "SessionStart",
                "additionalContext": reminder_msg,
            },
        }
        print(json.dumps(output_json))
        sys.exit(0)

    except Exception:
        # Fail gracefully without blocking the session
        sys.exit(0)


if __name__ == "__main__":
    main()
