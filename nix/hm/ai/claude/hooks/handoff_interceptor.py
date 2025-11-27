#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""UserPromptSubmit hook to intercept /handoff command and generate conversation summary.

This hook:
1. Detects when user types "/handoff"
2. Reads the session transcript to extract all messages
3. Calls `claude -p` to generate a handoff summary
4. Returns the summary as additional context to be shown to the user
"""

import json
import sys
import subprocess
from pathlib import Path


def extract_todos(transcript_path: str) -> list[dict]:
    """Extract current todo list from transcript JSONL file.

    Args:
        transcript_path: Path to the transcript JSONL file

    Returns:
        List of todo items with 'content', 'status', and 'activeForm'
    """
    latest_todos = []

    try:
        with open(transcript_path, "r") as f:
            for line in f:
                try:
                    entry = json.loads(line)

                    # Look for user type entries with toolUseResult containing todos
                    if entry.get("type") == "user" and "toolUseResult" in entry:
                        tool_result = entry["toolUseResult"]
                        # Get the latest todos from newTodos field
                        if "newTodos" in tool_result:
                            latest_todos = tool_result["newTodos"]

                except json.JSONDecodeError:
                    continue
    except FileNotFoundError:
        return []

    return latest_todos


def extract_messages(
    transcript_path: str, max_messages: int = 30, max_content_len: int = 500
) -> list[dict]:
    """Extract user and assistant messages from transcript JSONL file.

    Args:
        transcript_path: Path to the transcript JSONL file
        max_messages: Maximum number of recent messages to include
        max_content_len: Maximum length of each message content

    Returns:
        List of message dicts with 'role' and 'content'
    """
    messages = []

    try:
        with open(transcript_path, "r") as f:
            for line in f:
                try:
                    entry = json.loads(line)

                    # Skip non-message entries (file-history-snapshot, etc.)
                    if entry.get("type") not in ("user", "assistant"):
                        continue

                    # Extract message content
                    message = entry.get("message", {})
                    role = message.get("role")
                    content = message.get("content")

                    if not role or not content:
                        continue

                    # Handle different content formats
                    if isinstance(content, str):
                        text = content
                    elif isinstance(content, list):
                        # Check if this is a tool_result message (user messages with tool output)
                        # These contain verbose file contents - skip entirely
                        is_tool_result = any(
                            isinstance(b, dict) and b.get("type") == "tool_result"
                            for b in content
                        )
                        if is_tool_result:
                            continue
                        
                        # Extract text from content blocks (assistant messages)
                        text_parts = []
                        tool_count = 0
                        for block in content:
                            if isinstance(block, dict):
                                if block.get("type") == "text":
                                    block_text = block.get("text", "")
                                    # Skip "(no content)" placeholder
                                    if block_text.strip() and block_text.strip() != "(no content)":
                                        text_parts.append(block_text)
                                elif block.get("type") == "tool_use":
                                    tool_count += 1
                            elif isinstance(block, str):
                                text_parts.append(block)
                        
                        # Skip messages with only tool calls and no meaningful text
                        if not text_parts:
                            continue
                            
                        text = "\n".join(text_parts)
                        # Append tool count summary if tools were used
                        if tool_count > 0:
                            text += f" [+{tool_count} tool call(s)]"
                    else:
                        continue

                    # Skip empty messages
                    text = text.strip()
                    if not text:
                        continue

                    # Truncate long messages
                    if len(text) > max_content_len:
                        text = text[:max_content_len] + "..."

                    messages.append({"role": role, "content": text})

                except json.JSONDecodeError:
                    continue
    except FileNotFoundError:
        print(f"Transcript file not found: {transcript_path}", file=sys.stderr)
        return []

    # Return most recent messages
    return messages[-max_messages:] if len(messages) > max_messages else messages


def format_conversation(messages: list[dict]) -> str:
    """Format messages as a readable conversation."""
    lines = []
    for msg in messages:
        role = msg["role"].upper()
        content = msg["content"]
        lines.append(f"{role}: {content}\n")
    return "\n".join(lines)


def format_todos(todos: list[dict]) -> str:
    """Format todos as a readable list with status markers.

    Args:
        todos: List of todo items with 'content' and 'status'

    Returns:
        Formatted todo list string
    """
    if not todos:
        return ""

    lines = []
    for todo in todos:
        content = todo.get("content", "")
        status = todo.get("status", "pending")

        # Use checkboxes to show status
        if status == "completed":
            marker = "☑"
        elif status == "in_progress":
            marker = "▶"
        else:  # pending
            marker = "☐"

        lines.append(f"  {marker} {content}")

    return "\n".join(lines)


def generate_slug_from_messages(messages: list[dict]) -> str:
    """Generate a short slug from conversation messages.

    Args:
        messages: List of conversation messages

    Returns:
        A short slug (kebab-case)
    """
    # Get first few user messages to understand context
    user_messages = [m for m in messages if m["role"] == "user"][:3]

    if not user_messages:
        return "handoff"

    # Combine first few messages
    combined = " ".join(m["content"][:100] for m in user_messages)

    # Extract key words (simple approach)
    words = combined.lower().split()
    # Filter out common words
    stop_words = {
        "the",
        "a",
        "an",
        "and",
        "or",
        "but",
        "in",
        "on",
        "at",
        "to",
        "for",
        "of",
        "with",
        "by",
    }
    keywords = [w for w in words if w.isalnum() and len(w) > 3 and w not in stop_words][
        :3
    ]

    if keywords:
        return "-".join(keywords)
    else:
        return "handoff"


def generate_handoff_summary(
    messages: list[dict], project_dir: str = ".", todos: list[dict] = None
) -> str:
    """Generate handoff summary using claude -p.

    Args:
        messages: List of conversation messages
        project_dir: Project directory to run Claude in
        todos: List of todo items from transcript (optional)

    Returns:
        Generated summary text
    """
    if not messages:
        return "No conversation history available for handoff."

    from pathlib import Path

    absolute_project_dir = Path(project_dir).resolve().absolute()

    conversation = format_conversation(messages)

    # Format todos section if available
    todos_section = ""
    if todos:
        formatted_todos = format_todos(todos)
        if formatted_todos:
            todos_section = f"""
# Current Todo List (from session):
The following is the EXACT todo list from the session. Include ALL items in your handoff summary, preserving EXACT wording:

{formatted_todos}

"""

    # Create prompt for summarization
    prompt = f"""You are creating a handoff summary for a coding session in project directory: `{absolute_project_dir}`

Analyze this conversation and create a comprehensive handoff document that includes:

1. **Session Overview**: What was being worked on?
2. **Key Decisions**: Important technical decisions made
3. **Work Completed**: What was successfully implemented
4. **Pending Tasks**: What remains to be done
5. **Todo List**: List ALL todo items below in the "Current Todo List" section - copy them EXACTLY as shown, preserving markers (☑/▶/☐) and text verbatim
6. **Context for Next Session**: Critical information the next person needs to know
7. **Files Modified**: Key files that were changed (if mentioned) - use absolute paths relative to `{absolute_project_dir}`

Be concise but thorough. Format the output in markdown.
CRITICAL: The "Current Todo List" section below contains the EXACT todo items. You MUST copy them verbatim - do NOT paraphrase or summarize.
{todos_section}
# Conversation:

{conversation}

# Handoff Summary:"""

    try:
        # Call claude in print mode for non-interactive summarization
        # Set cwd to project directory so Claude has correct context
        result = subprocess.run(
            [
                "claude",
                "--model",
                "opencodeai/claude-haiku-4-5",
                "--allowedTools",
                "Write,Read,Bash(mkdir:*),Bash(touch:*),Bash(ls:*)",
                "-p",
                prompt,
            ],
            cwd=project_dir,
            capture_output=True,
            text=True,
            timeout=60,
        )

        if result.returncode == 0:
            return result.stdout.strip()
        else:
            error_msg = result.stderr.strip() if result.stderr else "Unknown error"
            return f"Error generating summary: {error_msg}"

    except subprocess.TimeoutExpired:
        return "Error: Summary generation timed out after 60 seconds"
    except FileNotFoundError:
        return "Error: 'claude' command not found. Is Claude CLI installed?"
    except Exception as e:
        return f"Error calling claude: {str(e)}"


def copy_to_clipboard(text: str) -> bool:
    """Copy text to clipboard using pbcopy.

    Args:
        text: Text to copy to clipboard

    Returns:
        True if successful, False otherwise
    """
    try:
        process = subprocess.Popen(["pbcopy"], stdin=subprocess.PIPE)
        process.communicate(text.encode("utf-8"))
        return process.returncode == 0
    except FileNotFoundError:
        return False
    except Exception:
        return False


def save_handoff_to_file(
    summary: str, messages: list[dict], project_dir: str, user_note: str = ""
) -> str:
    """Save handoff summary to .claude/handoffs/ directory.

    Args:
        summary: The generated handoff summary
        messages: List of conversation messages (for slug generation)
        project_dir: Project root directory
        user_note: Optional custom note from user (not sent to LLM)

    Returns:
        Filename of the saved handoff (relative to project)
    """
    from datetime import datetime

    # Create handoffs directory if it doesn't exist
    handoffs_dir = Path(project_dir) / ".claude" / "handoffs"
    handoffs_dir.mkdir(parents=True, exist_ok=True)

    # Generate slug and timestamp
    slug = generate_slug_from_messages(messages)
    timestamp = datetime.now().strftime("%Y-%m-%d-%H%M%S")
    filename = f"{slug}-{timestamp}.md"
    filepath = handoffs_dir / filename

    # Write the handoff summary
    with open(filepath, "w") as f:
        f.write(f"# Handoff: {slug}\n\n")
        f.write(f"**Created**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")

        # Include user note if provided
        if user_note:
            f.write("## User Note\n\n")
            f.write(f"> {user_note}\n\n")

        f.write("---\n\n")
        f.write(summary)
        f.write("\n\n---\n\n")
        f.write(f"**To resume**: Run `/pickup {filename}` in a new session\n")

    # Return relative path from project root
    return f".claude/handoffs/{filename}"


def main():
    """Main hook entry point."""
    try:
        # Read input from stdin
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(1)

    prompt = input_data.get("prompt", "").strip()

    # Check if this is a /handoff command
    if not prompt.startswith("/handoff"):
        # Not a handoff command, allow it to proceed normally
        return

    # This is a handoff command - intercept it
    # Extract custom message after "/handoff" (e.g., "/handoff custom msg" → "custom msg")
    user_note = prompt[len("/handoff"):].strip()

    transcript_path = input_data.get("transcript_path", "")

    if not transcript_path:
        print("Error: No transcript_path provided", file=sys.stderr)
        sys.exit(2)

    # Extract messages and todos from transcript
    messages = extract_messages(transcript_path)
    todos = extract_todos(transcript_path)

    if not messages:
        error_msg = "No conversation history found to summarize."
        output = {
            "decision": "block",
            "reason": error_msg,
            "hookSpecificOutput": {"hookEventName": "UserPromptSubmit"},
        }
        print(json.dumps(output))
        sys.exit(0)

    # Get project directory (cwd or current working directory)
    project_dir = input_data.get("cwd", ".")

    # Generate handoff summary with correct project directory context and todos
    summary = generate_handoff_summary(messages, project_dir, todos)

    # Save handoff to file
    try:
        handoff_file = save_handoff_to_file(summary, messages, project_dir, user_note)
    except Exception as e:
        error_msg = f"Error saving handoff: {str(e)}"
        output = {
            "decision": "block",
            "reason": error_msg,
            "hookSpecificOutput": {"hookEventName": "UserPromptSubmit"},
        }
        print(json.dumps(output))
        sys.exit(0)

    # Format the response message
    pickup_command = f"/pickup {Path(handoff_file).name}"

    # Try to copy pickup command to clipboard
    clipboard_copied = copy_to_clipboard(pickup_command)

    clipboard_status = "📋 Copied to clipboard!" if clipboard_copied else ""

    formatted_message = f"""✅ **Handoff Created Successfully**

📝 **File**: `{handoff_file}`

🔄 **Next Steps**:
1. Run `/new` to start a fresh session
2. Run the command below to resume:

{pickup_command}
{clipboard_status}
"""

    # Return JSON output using Claude's standard format
    # "decision": "block" prevents the /handoff prompt from reaching Claude
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
