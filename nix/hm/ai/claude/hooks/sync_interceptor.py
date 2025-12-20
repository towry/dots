#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""UserPromptSubmit hook to intercept /sync command and save session without quitting.

This hook:
1. Detects when user types "/sync"
2. Reads the session transcript to extract all messages
3. Saves messages to the same format as session_save.py
4. Avoids duplicate messages when run multiple times in the same session
"""

import json
import os
import sys
from datetime import datetime
from pathlib import Path

# Same constants as session_save.py
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
    """Parse the JSONL transcript file and return formatted messages.

    Returns:
        List of (msg_type, content, line_number) tuples
    """
    messages = []
    try:
        with open(transcript_path, "r") as f:
            line_number = 0
            for line in f:
                line_number += 1
                line = line.strip()
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue

                entry_type = entry.get("type")

                # Skip non-message entries
                if entry_type not in ("user", "assistant"):
                    continue

                # Skip meta messages
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
                            messages.append(("user", text_content, line_number))
                    elif isinstance(content, str) and content:
                        # Skip command messages
                        if "<command-" in content or "<local-command" in content:
                            continue
                        messages.append(("user", content, line_number))

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
                                        messages.append(("tool_call", format_tool_call(tool_name, tool_input), line_number))
                        if text_parts:
                            messages.append(("agent", "\n".join(text_parts), line_number))
                    elif isinstance(content, str) and content.strip():
                        messages.append(("agent", content.strip(), line_number))

    except Exception as e:
        print(f"Error parsing transcript: {e}", file=sys.stderr)

    return messages


def save_session(cwd: str, all_messages: list, session_id: str):
    """Save formatted messages to session file (overwrites existing file).

    Args:
        cwd: Project directory
        all_messages: List of (msg_type, content, line_number) tuples from transcript
        session_id: Session ID
    """
    if not all_messages or not session_id:
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
    # Strip line_number from messages for description extraction
    messages_for_desc = [(msg_type, content) for msg_type, content, _ in all_messages]
    description = extract_description_from_messages(messages_for_desc)
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")

    # Use existing filename or create new one
    if existing_file:
        filepath = existing_file
    else:
        filename = f"{timestamp}-session-{description}-ID_{session_id}.md"
        filepath = sessions_dir / filename

    # Format output - always write all messages
    output_lines = []
    for msg_type, content, _ in all_messages:
        if msg_type == "user":
            output_lines.append(f"<user>\n{content}\n</user>\n")
        elif msg_type == "agent":
            output_lines.append(f"<agent>\n{content}\n</agent>\n")
        elif msg_type == "tool_call":
            output_lines.append(f"<tool_call>\n{content}\n</tool_call>\n")

    try:
        # Always overwrite with complete session state
        with open(filepath, "w") as f:
            f.write("\n".join(output_lines))
        # Set restrictive permissions
        os.chmod(filepath, 0o600)

        return filepath, len(all_messages)
    except Exception as e:
        print(f"Error saving session: {e}", file=sys.stderr)
        return None, 0


def main():
    """Main hook entry point."""
    try:
        # Read input from stdin
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(1)

    prompt = input_data.get("prompt", "").strip()

    # Check if this is a /sync command
    if not prompt.startswith("/sync"):
        # Not a sync command, allow it to proceed normally
        return

    # This is a sync command - intercept it
    transcript_path = input_data.get("transcript_path", "")
    session_id = input_data.get("session_id", "")
    cwd = input_data.get("cwd", ".")

    if not transcript_path:
        print("Error: No transcript_path provided", file=sys.stderr)
        sys.exit(2)

    if not session_id:
        print("Error: No session_id provided", file=sys.stderr)
        sys.exit(2)

    # Extract messages from transcript
    messages = parse_transcript(transcript_path)

    if not messages:
        error_msg = "No conversation history found to save."
        output = {
            "decision": "block",
            "reason": error_msg,
            "hookSpecificOutput": {"hookEventName": "UserPromptSubmit"},
        }
        print(json.dumps(output))
        sys.exit(0)

    # Save session
    try:
        result = save_session(cwd, messages, session_id)
        if result is None:
            error_msg = "Failed to save session."
            output = {
                "decision": "block",
                "reason": error_msg,
                "hookSpecificOutput": {"hookEventName": "UserPromptSubmit"},
            }
            print(json.dumps(output))
            sys.exit(0)

        filepath, total_count = result

        # Format the response message
        formatted_message = f"""✅ **Session Synced Successfully**

📝 **File**: `.claude/sessions/{filepath.name}`
📊 **Total Messages**: {total_count}

The session has been saved to disk. You can continue working in this session.
"""

    except Exception as e:
        error_msg = f"Error during sync: {str(e)}"
        output = {
            "decision": "block",
            "reason": error_msg,
            "hookSpecificOutput": {"hookEventName": "UserPromptSubmit"},
        }
        print(json.dumps(output))
        sys.exit(0)

    # Return JSON output using Claude's standard format
    # "decision": "block" prevents the /sync prompt from reaching Claude
    # "reason" is shown to the user
    output = {
        "decision": "block",
        "reason": formatted_message.strip(),
        "hookSpecificOutput": {"hookEventName": "UserPromptSubmit"},
    }

    # Print JSON to stdout with exit code 0
    print(json.dumps(output))
    sys.exit(0)


if __name__ == "__main__":
    main()
