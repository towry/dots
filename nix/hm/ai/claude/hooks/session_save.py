#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

"""Hook: SessionEnd - Save session chat messages to project directory.

Saves conversation messages to `.claude/sessions/<timestamp>-session-<description>.txt`
in the format:
    <user>...</user>
    <agent>...</agent>
    <tool_call>...</tool_call>  (for important tool calls)
"""

import json
import os
import sys
from datetime import datetime
from pathlib import Path


IMPORTANT_TOOLS = {"Bash", "Execute", "Write", "Edit", "Create", "Task"}


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


def save_session(cwd: str, messages: list, session_id: str):
    """Save formatted messages to session file."""
    if not messages:
        return

    # Create sessions directory
    sessions_dir = Path(cwd) / ".claude" / "sessions"
    sessions_dir.mkdir(parents=True, exist_ok=True)

    # Generate filename
    description = extract_description_from_messages(messages)
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    filename = f"{timestamp}-session-{description}.txt"
    filepath = sessions_dir / filename

    # Format and write output
    output_lines = []
    for msg_type, content in messages:
        if msg_type == "user":
            output_lines.append(f"<user>\n{content}\n</user>\n")
        elif msg_type == "agent":
            output_lines.append(f"<agent>\n{content}\n</agent>\n")
        elif msg_type == "tool_call":
            output_lines.append(f"<tool_call>\n{content}\n</tool_call>\n")

    try:
        with open(filepath, "w") as f:
            f.write("\n".join(output_lines))
        # Set restrictive permissions
        os.chmod(filepath, 0o600)
    except Exception as e:
        print(f"Error saving session: {e}", file=sys.stderr)


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

    if not transcript_path or not os.path.exists(transcript_path):
        sys.exit(0)

    if not cwd:
        sys.exit(0)

    messages = parse_transcript(transcript_path)
    save_session(cwd, messages, session_id)

    sys.exit(0)


if __name__ == "__main__":
    main()
