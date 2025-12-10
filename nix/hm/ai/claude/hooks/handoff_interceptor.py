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

# Configuration constants
MAX_MESSAGES = 30
MAX_MESSAGE_LEN = 500
MAX_CONVERSATION_CHARS = 8000
RECENT_PROTECT_COUNT = 8
HANDOFF_MODEL = "openrouter/qwen/qwen3-coder"


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


def is_low_value_chatter(text: str, role: str) -> bool:
    """Check if message is low-value filler/chatter."""
    t = text.lower().strip()

    if len(t) < 40:
        filler_phrases = [
            "got it",
            "sounds good",
            "ok",
            "okay",
            "let me",
            "i'll",
            "i will",
            "now i'll",
            "now i will",
            "starting with",
            "i'm going to",
            "let's start by",
        ]
        if any(p in t for p in filler_phrases):
            return True

    meta_phrases = [
        "let me check",
        "let me see",
        "i'll check",
        "i will check",
        "i'll start by",
        "now let me",
        "let me load",
        "loading the",
        "running the",
    ]
    if len(t) < 140 and any(p in t for p in meta_phrases):
        return True

    return False


def looks_like_doc_dump(text: str) -> bool:
    """Check if message is a generic documentation dump."""
    t = text.lower()
    if len(t) > 400:
        heading_patterns = ("\n## ", "\n### ", "\n- ", "\n* ")
        heading_count = sum(1 for h in heading_patterns if h in text)
        if heading_count >= 2:
            return True
        if ("this skill" in t or "overview" in t) and "##" in text:
            return True
    return False


def is_decision_or_summary(text: str) -> bool:
    """Check if message contains decision, summary, or plan content."""
    t = text.lower()
    keywords = [
        "decision",
        "we decided",
        "we chose",
        "we'll",
        "summary",
        "recap",
        "overview of",
        "next steps",
        "todo",
        "to-do",
        "pending tasks",
        "completed",
        "implemented",
        "fixed",
        "resolved",
        "the plan is",
        "we will do",
    ]
    return any(k in t for k in keywords)


def is_user_intent_or_question(text: str, role: str) -> bool:
    """Check if message is user intent/question."""
    if role != "user":
        return False
    t = text.lower()
    intent_keywords = [
        "need to",
        "i want to",
        "please",
        "can you",
        "how do i",
        "we are going to",
        "so we need",
        "the purpose is",
    ]
    return "?" in text or any(k in t for k in intent_keywords)


def filter_messages_for_handoff(
    messages: list[dict],
    max_total_chars: int = MAX_CONVERSATION_CHARS,
    recent_protect_count: int = RECENT_PROTECT_COUNT,
) -> list[dict]:
    """Filter messages to remove noise and enforce character budget.

    Args:
        messages: List of message dicts with 'role' and 'content'
        max_total_chars: Maximum total character budget for conversation
        recent_protect_count: Number of recent messages to always protect

    Returns:
        Filtered list of messages
    """
    if not messages:
        return messages

    # Find first user message (session intent)
    first_user_idx = next(
        (i for i, m in enumerate(messages) if m["role"] == "user"),
        None,
    )

    # First pass: remove obvious low-value messages
    annotated = []
    for i, msg in enumerate(messages):
        text, role = msg["content"], msg["role"]

        # Mark protected messages
        protected = (
            (i == first_user_idx and first_user_idx is not None)
            or is_decision_or_summary(text)
            or is_user_intent_or_question(text, role)
        )

        # Mark low-value messages
        low_value = (not protected) and (
            is_low_value_chatter(text, role) or looks_like_doc_dump(text)
        )

        if low_value:
            continue  # drop this message

        annotated.append({"index": i, "msg": msg, "protected": protected})

    # Second pass: enforce character budget
    total_chars = sum(len(a["msg"]["content"]) for a in annotated)

    if total_chars <= max_total_chars:
        # Already under budget, return in original order
        annotated.sort(key=lambda a: a["index"])
        return [a["msg"] for a in annotated]

    # Over budget: protect tail and drop oldest non-protected first
    tail_start_idx = max(0, len(annotated) - recent_protect_count)

    i = 0
    while total_chars > max_total_chars and i < tail_start_idx:
        a = annotated[i]
        if not a["protected"]:
            total_chars -= len(a["msg"]["content"])
            annotated.pop(i)
            tail_start_idx -= 1
            continue
        i += 1

    # If still over budget, drop protected messages from head (but not tail)
    while total_chars > max_total_chars and len(annotated) > recent_protect_count:
        a = annotated[0]
        total_chars -= len(a["msg"]["content"])
        annotated.pop(0)
        tail_start_idx -= 1

    # Sort back to original order
    annotated.sort(key=lambda a: a["index"])
    return [a["msg"] for a in annotated]


def extract_messages(
    transcript_path: str,
    max_messages: int = MAX_MESSAGES,
    max_content_len: int = MAX_MESSAGE_LEN,
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
                                    if (
                                        block_text.strip()
                                        and block_text.strip() != "(no content)"
                                    ):
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

    Raises:
        subprocess.TimeoutExpired: If claude command times out
        FileNotFoundError: If claude command is not found
        Exception: If command execution fails
    """
    if not messages:
        raise ValueError("No conversation history available for handoff.")

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
    prompt = f"""You are creating a **handoff document** to transfer context from a completed session to the next session in project directory: `{absolute_project_dir}`

This is NOT a summary of what's currently happening - it's documentation of what was COMPLETED and what still needs work.

Analyze this conversation and create a comprehensive handoff document with these sections:

1. **Previous Session Overview**: Brief summary of what was worked on and accomplished
2. **Key Decisions Made**: Important technical decisions that were made and why
3. **Work Completed**: What was successfully implemented in this session
4. **Current Blockers/Issues**: Any unresolved problems or blocking issues
5. **Next Steps (TODO)**: What needs to be done next (also listed verbatim below)
6. **Context for Next Session**: Critical information the next person MUST know to resume
7. **Files Modified**: Key files that were changed (if mentioned) - use absolute paths relative to `{absolute_project_dir}`
8. **Claude Skills Required**: List skills that were used or are needed for continuing work, include in "How to Resume" section

Be concise but thorough. Format the output in markdown.

CRITICAL: The "Current Todo List" section contains the EXACT todo items from this session. You MUST copy them verbatim with markers (☑/▶/☐) - do NOT paraphrase or summarize.
{todos_section}
# Previous Session Conversation:

{conversation}

# Handoff Document:"""

    # Call claude in print mode for non-interactive summarization
    # Set cwd to project directory so Claude has correct context
    result = subprocess.run(
        [
            "claude",
            "--model",
            HANDOFF_MODEL,
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
        raise RuntimeError(f"Claude command failed: {error_msg}")


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
    user_note = prompt[len("/handoff") :].strip()

    transcript_path = input_data.get("transcript_path", "")

    if not transcript_path:
        print("Error: No transcript_path provided", file=sys.stderr)
        sys.exit(2)

    # Extract messages and todos from transcript
    messages = extract_messages(transcript_path)
    # Filter messages to remove noise and enforce character budget
    messages = filter_messages_for_handoff(messages)
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
    try:
        summary = generate_handoff_summary(messages, project_dir, todos)
    except subprocess.TimeoutExpired:
        print("Error: Summary generation timed out after 60 seconds", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error generating summary: {str(e)}", file=sys.stderr)
        sys.exit(1)

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
