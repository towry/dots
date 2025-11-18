#!/usr/bin/env python3
"""
Claude Code statusline script
Displays contextual information about the current session
"""

# Customize these icons to your preference
# Examples:
# - Use emojis: "📂", "⏳", "💰", etc.
# - Use nerdfonts: "", "", "", etc.
# - Use simple symbols: "📁", "⏱️", "$", etc.
ICON_DIR = "󰋜"
ICON_BRANCH = "󰊢"
ICON_SESSION = "󰓹"
ICON_CONTEXT = ""
ICON_COST = ""
ICON_LINES = ""
ICON_DURATION = "󱑆"

import json
import sys
import os
import subprocess


def get_git_branch(cwd):
    """Get the current git branch if in a git repository"""
    try:
        # Change to the working directory
        original_cwd = os.getcwd()
        os.chdir(cwd)

        # Check if we're in a git repo
        result = subprocess.run(
            ["git", "rev-parse", "--git-dir"], capture_output=True, text=True, timeout=1
        )

        if result.returncode != 0:
            os.chdir(original_cwd)
            return ""

        # Get current branch
        result = subprocess.run(
            ["git", "branch", "--show-current"],
            capture_output=True,
            text=True,
            timeout=1,
        )

        os.chdir(original_cwd)

        branch = result.stdout.strip()
        return f" | {ICON_BRANCH} {branch}" if branch else ""
    except Exception:
        return ""


def get_token_metrics(transcript_path):
    """Calculate token metrics from transcript file"""
    try:
        if not os.path.exists(transcript_path):
            return None

        with open(transcript_path, "r") as f:
            lines = f.read().strip().split("\n")

        input_tokens = 0
        output_tokens = 0
        cached_tokens = 0
        context_length = 0

        most_recent_main_chain_entry = None
        most_recent_timestamp = None

        for line in lines:
            try:
                data = json.loads(line)
                if data.get("message", {}).get("usage"):
                    usage = data["message"]["usage"]
                    input_tokens += usage.get("input_tokens", 0)
                    output_tokens += usage.get("output_tokens", 0)
                    cached_tokens += usage.get("cache_read_input_tokens", 0)
                    cached_tokens += usage.get("cache_creation_input_tokens", 0)

                    # Track most recent main chain entry
                    if not data.get("isSidechain", False) and data.get("timestamp"):
                        timestamp = data["timestamp"]
                        if (
                            most_recent_timestamp is None
                            or timestamp > most_recent_timestamp
                        ):
                            most_recent_timestamp = timestamp
                            most_recent_main_chain_entry = data
            except:
                continue

        # Calculate context length from most recent main chain message
        if most_recent_main_chain_entry and most_recent_main_chain_entry.get(
            "message", {}
        ).get("usage"):
            usage = most_recent_main_chain_entry["message"]["usage"]
            context_length = (
                usage.get("input_tokens", 0)
                + usage.get("cache_read_input_tokens", 0)
                + usage.get("cache_creation_input_tokens", 0)
            )

        total_tokens = input_tokens + output_tokens + cached_tokens

        return {
            "input_tokens": input_tokens,
            "output_tokens": output_tokens,
            "cached_tokens": cached_tokens,
            "total_tokens": total_tokens,
            "context_length": context_length,
        }
    except:
        return None


def format_tokens(count):
    """Format token count in human-readable format"""
    if count >= 1000000:
        return f"{count / 1000000:.1f}M"
    if count >= 1000:
        return f"{count / 1000:.1f}k"
    return str(count)


def format_cost(cost_usd):
    """Format cost in USD"""
    if cost_usd is None or cost_usd == 0:
        return ""
    return f" | {ICON_COST} ${cost_usd:.4f}"


def format_lines(added, removed):
    """Format lines added/removed"""
    if (added is None or added == 0) and (removed is None or removed == 0):
        return ""

    parts = []
    if added and added > 0:
        parts.append(f"+{added}")
    if removed and removed > 0:
        parts.append(f"-{removed}")

    return f" | {ICON_LINES} {'/'.join(parts)}" if parts else ""


def format_duration(duration_ms):
    """Format duration in human-readable format"""
    if duration_ms is None or duration_ms == 0:
        return ""

    seconds = duration_ms / 1000
    if seconds < 60:
        return f" | {ICON_DURATION} {seconds:.1f}s"
    else:
        minutes = int(seconds // 60)
        secs = int(seconds % 60)
        return f" | {ICON_DURATION} {minutes}m {secs}s"


def format_context_stats(token_metrics):
    """Format context statistics"""
    if not token_metrics:
        return ""

    context_length = token_metrics.get("context_length", 0)
    if context_length == 0:
        return ""

    # Calculate context percentage (using 200k as default max)
    max_tokens = 200000
    percentage = min(100, (context_length / max_tokens) * 100)

    return f" | {ICON_CONTEXT} {format_tokens(context_length)} ({percentage:.1f}%)"


def format_session_id(session_id):
    """Format session ID (shortened)"""
    if not session_id:
        return ""
    # Show first 8 characters of session ID
    return f" | {ICON_SESSION} {session_id[:8]}"


def main():
    try:
        # Read JSON from stdin
        data = json.load(sys.stdin)

        # Extract values
        model = data.get("model", {}).get("display_name", "Unknown")
        current_dir = data.get("workspace", {}).get("current_dir", os.getcwd())
        dir_name = os.path.basename(current_dir)

        # Optional: Get git branch
        git_branch = get_git_branch(current_dir)

        # Optional: Get cost information
        cost = data.get("cost", {})
        cost_info = format_cost(cost.get("total_cost_usd"))

        # Optional: Get lines changed
        lines_info = format_lines(
            cost.get("total_lines_added"), cost.get("total_lines_removed")
        )

        # Optional: Get context states
        session_info = format_session_id(data.get("session_id"))
        duration_info = format_duration(cost.get("total_duration_ms"))

        # Optional: Get token metrics and context stats
        token_metrics = None
        transcript_path = data.get("transcript_path")
        if transcript_path:
            token_metrics = get_token_metrics(transcript_path)

        context_stats = format_context_stats(token_metrics)

        # Build status line
        status = f"[{model}]  {dir_name}{git_branch}{session_info}{context_stats}{cost_info}{lines_info}{duration_info}"

        print(status)

    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
