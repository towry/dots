#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

"""Hook: SessionEnd - Save session chat messages to project directory.

Saves conversation messages to `.claude/sessions/<timestamp>-session-<title>-ID_<session_id>.md`
in the format:
    <user>...</user>
    <agent>...</agent>
    <tool_call>...</tool_call>  (for important tool calls)

If a file with the same session_id exists, appends to it instead of creating a new file.
Also generates a summary (`.claude/sessions/<timestamp>-summary-ID_<session_id>.md`) for the
next session to pick up. Summary files are overwritten (updated) if they already exist.
"""

import json
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path


IMPORTANT_TOOLS = {"Bash", "Execute", "Write", "Edit", "Create", "Task"}
# Use aichat with session-summary role to avoid interfering with Claude sessions
SUMMARY_ROLE = "session-summary"  # aichat role name
MAX_SUMMARY_MESSAGES = 8


def extract_description_from_messages(messages: list) -> str:
    """Extract a short description from the first user message."""
    for msg_type, content in messages:
        if msg_type == "user" and content:
            # Take first 30 chars, clean for filename
            desc = content[:30].strip()
            desc = "".join(c if c.isalnum() or c in " -_" else "" for c in desc)
            desc = desc.replace(" ", "-").lower()
            return desc or "session"
    return "session"


def format_content(content) -> str:
    """Format message content to string."""
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for part in content:
            if isinstance(part, dict):
                if part.get("type") == "text":
                    parts.append(part.get("text", ""))
                elif part.get("type") == "tool_use":
                    # Skip tool_use in content blocks, handled separately
                    pass
                elif part.get("type") == "tool_result":
                    pass
            elif isinstance(part, str):
                parts.append(part)
        return "\n".join(parts)
    return str(content)


def format_tool_call(tool_name: str, tool_input: dict) -> str:
    """Format a tool call for output."""
    if tool_name == "Bash" or tool_name == "Execute":
        cmd = tool_input.get("command", "")
        return f"[{tool_name}] {cmd}"
    elif tool_name == "Write" or tool_name == "Create":
        path = tool_input.get("file_path", tool_input.get("path", ""))
        return f"[{tool_name}] {path}"
    elif tool_name == "Edit":
        path = tool_input.get("file_path", "")
        return f"[{tool_name}] {path}"
    elif tool_name == "Task":
        desc = tool_input.get("description", "")
        return f"[{tool_name}] {desc}"
    else:
        return f"[{tool_name}]"


def parse_transcript(transcript_path: str) -> list:
    """Parse the JSONL transcript file and return formatted messages."""
    messages = []
    try:
        with open(transcript_path, "r") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue

                entry_type = entry.get("type")

                # Skip non-message entries (queue-operation, file-history-snapshot, etc.)
                if entry_type not in ("user", "assistant"):
                    continue

                # Skip meta messages (system injections, command messages)
                if entry.get("isMeta"):
                    continue

                message = entry.get("message", {})
                role = message.get("role")
                content = message.get("content", "")

                # User message
                if entry_type == "user" and role == "user":
                    # Skip tool_result messages
                    if isinstance(content, list):
                        has_tool_result = any(
                            isinstance(p, dict) and p.get("type") == "tool_result"
                            for p in content
                        )
                        if has_tool_result:
                            continue
                        # Check for interrupt messages
                        text_content = format_content(content)
                        if text_content and "[Request interrupted by user]" not in text_content:
                            messages.append(("user", text_content))
                    elif isinstance(content, str) and content:
                        # Skip command messages
                        if "<command-" in content or "<local-command" in content:
                            continue
                        messages.append(("user", content))

                # Assistant message
                elif entry_type == "assistant" and role == "assistant":
                    if isinstance(content, list):
                        text_parts = []
                        for part in content:
                            if isinstance(part, dict):
                                if part.get("type") == "text":
                                    text = part.get("text", "").strip()
                                    if text:
                                        text_parts.append(text)
                                elif part.get("type") == "tool_use":
                                    tool_name = part.get("name", "")
                                    tool_input = part.get("input", {})
                                    if tool_name in IMPORTANT_TOOLS:
                                        messages.append(("tool_call", format_tool_call(tool_name, tool_input)))
                        if text_parts:
                            messages.append(("agent", "\n".join(text_parts)))
                    elif isinstance(content, str) and content.strip():
                        messages.append(("agent", content.strip()))

    except Exception as e:
        print(f"Error parsing transcript: {e}", file=sys.stderr)

    return messages


def generate_summary(messages: list, cwd: str) -> str:
    """Generate a brief summary using aichat with session-summary role.

    Args:
        messages: List of (msg_type, content) tuples
        cwd: Project directory context

    Returns:
        Generated summary text (1-2 sentences)
    """
    if not messages:
        return ""

    # Filter to user/agent messages first, then take last N
    relevant = [(t, c) for t, c in messages if t in ("user", "agent")]
    recent = []
    for msg_type, content in relevant[-MAX_SUMMARY_MESSAGES:]:
        # Truncate long messages
        text = content[:300] + "..." if len(content) > 300 else content
        role = "USER" if msg_type == "user" else "ASSISTANT"
        recent.append(f"{role}: {text}")

    if not recent:
        return ""

    conversation = "\n\n".join(recent)

    prompt = f"""Project: {cwd}

Conversation:
{conversation}"""

    try:
        # Use aichat with session-summary role via stdin
        result = subprocess.run(
            ["aichat", "-r", SUMMARY_ROLE],
            input=prompt,
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=30,
        )

        if result.returncode == 0:
            summary = result.stdout.strip()
            # Remove any markdown formatting
            summary = summary.replace("**", "").replace("*", "")
            if summary:
                print(f"✓ Session summary generated ({len(summary)} chars)", file=sys.stderr)
                return summary
            else:
                print("⚠ aichat returned empty summary", file=sys.stderr)
                return ""
        else:
            error_msg = result.stderr.strip() if result.stderr else "unknown error"
            print(f"✗ aichat failed (exit {result.returncode}): {error_msg}", file=sys.stderr)
            return ""

    except subprocess.TimeoutExpired:
        print("✗ aichat timed out after 30s", file=sys.stderr)
        return ""
    except FileNotFoundError:
        print("✗ aichat command not found", file=sys.stderr)
        return ""
    except Exception as e:
        print(f"✗ aichat error: {e}", file=sys.stderr)
        return ""


def save_summary(cwd: str, summary: str, timestamp: str, session_id: str, session_file: str = ""):
    """Save summary to session-summary directory with session ID.

    NOTE: This function is paired with `session_summary.py` which reads these files
    on SessionStart. If you change the directory path or filename pattern here,
    you MUST update `read_previous_summary()` in session_summary.py to match.

    Current contract:
        - Directory: .claude/session-summary/
        - Pattern: {timestamp}-summary-ID_{session_id}.md

    Args:
        cwd: Project directory
        summary: Summary text
        timestamp: Timestamp string (YYYYMMDD-HHMMSS)
        session_id: Session ID
        session_file: Path to the full session file (relative to cwd)
    """
    if not summary or not session_id:
        return

    summary_dir = Path(cwd) / ".claude" / "session-summary"
    summary_dir.mkdir(parents=True, exist_ok=True)

    # Look for existing summary file with this session_id
    existing_file = None
    for file in summary_dir.glob(f"*-summary-ID_{session_id}.md"):
        existing_file = file
        break

    # Use existing file or create new one with timestamp
    summary_file = existing_file or summary_dir / f"{timestamp}-summary-ID_{session_id}.md"

    # Append session file reference if available
    content = summary
    if session_file:
        content = f"{summary}\n\nFull session: {session_file}"

    try:
        # Always overwrite summary (update, don't append)
        with open(summary_file, "w") as f:
            f.write(content)
        os.chmod(summary_file, 0o600)
        print(f"✓ Summary saved to {summary_file.name}", file=sys.stderr)
    except Exception as e:
        print(f"✗ Failed to save summary: {e}", file=sys.stderr)


def save_session(cwd: str, messages: list, session_id: str, reason: str = ""):
    """Save formatted messages to session file.

    If a session file with the same session_id exists, append to it.
    Otherwise, create a new file with the session_id in the name.
    """
    if not messages or not session_id:
        return

    # Create sessions directory
    sessions_dir = Path(cwd) / ".claude" / "sessions"
    sessions_dir.mkdir(parents=True, exist_ok=True)

    # Look for existing session file with this session_id
    existing_file = None
    for file in sessions_dir.glob(f"*-session-*-ID_{session_id}.md"):
        existing_file = file
        break

    # Generate filename for new file
    description = extract_description_from_messages(messages)
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")

    if existing_file:
        filepath = existing_file
        mode = "a"  # Append mode
    else:
        filename = f"{timestamp}-session-{description}-ID_{session_id}.md"
        filepath = sessions_dir / filename
        mode = "w"  # Write mode for new file

    # Format output
    output_lines = []
    for msg_type, content in messages:
        if msg_type == "user":
            output_lines.append(f"<user>\n{content}\n</user>\n")
        elif msg_type == "agent":
            output_lines.append(f"<agent>\n{content}\n</agent>\n")
        elif msg_type == "tool_call":
            output_lines.append(f"<tool_call>\n{content}\n</tool_call>\n")

    try:
        with open(filepath, mode) as f:
            if mode == "a":
                # Add separator for appended content
                f.write("\n---\n\n")
            f.write("\n".join(output_lines))
        # Set restrictive permissions
        os.chmod(filepath, 0o600)
    except Exception as e:
        print(f"Error saving session: {e}", file=sys.stderr)

    # Generate and save summary for next session (only on "clear" reason)
    if reason == "clear":
        summary = generate_summary(messages, cwd)
        # Pass relative session file path
        session_file_rel = str(filepath.relative_to(cwd)) if filepath else ""
        save_summary(cwd, summary, timestamp, session_id, session_file_rel)
    elif reason:
        print(f"⊘ Summary skipped (reason='{reason}', need 'clear')", file=sys.stderr)


def main():
    try:
        raw = sys.stdin.read()
        if not raw:
            sys.exit(0)
        input_data = json.loads(raw)
    except json.JSONDecodeError:
        sys.exit(0)

    hook_event = input_data.get("hook_event_name")
    if hook_event != "SessionEnd":
        sys.exit(0)

    transcript_path = input_data.get("transcript_path", "")
    cwd = os.environ.get("CLAUDE_PROJECT_DIR") or input_data.get("cwd", "")
    session_id = input_data.get("session_id", "")
    reason = input_data.get("reason", "")

    if not transcript_path or not os.path.exists(transcript_path):
        sys.exit(0)

    if not cwd:
        sys.exit(0)

    messages = parse_transcript(transcript_path)
    save_session(cwd, messages, session_id, reason)

    sys.exit(0)


if __name__ == "__main__":
    main()
