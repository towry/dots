#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "python-dotenv",
# ]
# ///
"""PreToolUse hook to block forbidden Bash commands and suggest alternatives.

Improvements (2025-11-25):
- Eliminate regex false positives where words like "find" or "grep" appear only as arguments.
- Tokenize shell segments and match ONLY the leading command tokens.
- Preserve multi-word command matching (e.g. "jj git init").
- Correctly allow `grep` when it is part of a pipeline segment (preceded by `|`).

Blocked when segment FIRST tokens match any forbidden sequence:
- find          -> suggest fd
- grep (non‑pipeline) -> suggest rg
- jj git init   -> ask user
- jj git push   -> ask user
- git init      -> ask user
- git push      -> ask user
- git clean     -> ask user

Return code 2 blocks execution; 0 allows.
"""
from __future__ import annotations

import json
import re
import shlex
import sys
from typing import List, Dict, Any

# Structured forbidden command definitions (ordered by specificity)
FORBIDDEN_COMMANDS: List[Dict[str, Any]] = [
    {
        "sequence": ["find"],
        "name": "find",
        "alternative": "fd",
        "examples": [
            'fd "*.py"                       # Find Python files',
            'fd -e js "component"            # Find JS files matching "component"',
            "fd -d 2                        # Search 2 directories deep",
            "fd --hidden                      # Include hidden files",
            'fd -i "config"                  # Case-insensitive search',
        ],
        "benefits": "",
    },
    {
        "sequence": ["grep"],
        "name": "grep",
        "alternative": "rg",
        "examples": [
            'rg "TODO"                         # Search for TODO in all files',
            'rg -tpy "import"                  # Search only in Python files',
            'rg -tjs "useState"                # Search only in JavaScript files',
            'rg --glob "*.md" "# Heading"      # Search only in markdown files',
            'rg -C 2 "error"                  # Show 2 lines of context',
            'rg -i "error"                     # Case-insensitive search',
        ],
        "benefits": "",
    },
    {
        "sequence": ["jj", "git", "init"],
        "name": "jj git init",
        "alternative": "ask user to run it",
        "examples": ["User, please initialize the jj git repo."],
        "benefits": "Prevents accidental jj repo creation",
    },
    {
        "sequence": ["jj", "git", "push"],
        "name": "jj git push",
        "alternative": "ask user to run it",
        "examples": ["User, please push the changes with jj."],
        "benefits": "Prevents accidental jj pushes",
    },
    {
        "sequence": ["git", "init"],
        "name": "git init",
        "alternative": "ask user to run it",
        "examples": ["User, please initialize the git repository."],
        "benefits": "Prevents accidental repo creation",
    },
    {
        "sequence": ["git", "push"],
        "name": "git push",
        "alternative": "ask user to run it",
        "examples": ["User, please push the changes."],
        "benefits": "Prevents accidental pushes",
    },
    {
        "sequence": ["git", "clean"],
        "name": "git clean",
        "alternative": "ask user to run it",
        "examples": ["User, please clean the repository."],
        "benefits": "Prevents accidental deletion of untracked files",
    },
]

SEPARATOR_REGEX = r"(\|\|?|&&|;|&)"  # capture |, ||, &&, ;, &


def split_segments(command: str):
    """Split a command string into segments with knowledge of preceding separator.

    Each segment dict contains:
        segment: str  - the raw segment text (trimmed)
        separator_before: str | None - one of |, ||, &&, ;, & that preceded it
    """
    parts = re.split(SEPARATOR_REGEX, command)
    segments = []
    sep_before = None
    for part in parts:
        if not part:
            continue
        if re.fullmatch(SEPARATOR_REGEX, part):
            sep_before = part  # applies to next segment
            continue
        seg = part.strip()
        if seg:
            segments.append({"segment": seg, "separator_before": sep_before})
            sep_before = None
    return segments


def tokenize(segment: str) -> List[str]:
    try:
        return shlex.split(segment)
    except Exception:
        # On failure, return empty list so it won't match
        return []


def match_forbidden(tokens: List[str]):
    lowered = [t.lower() for t in tokens]
    for entry in FORBIDDEN_COMMANDS:
        seq = entry["sequence"]
        if len(lowered) >= len(seq) and lowered[: len(seq)] == [s.lower() for s in seq]:
            return entry
    return None


def check_forbidden_bash_commands(tool_name: str, tool_input: dict):
    """Check if tool input contains forbidden Bash commands using segment-based parsing."""
    if tool_name != "Bash":
        return None

    command = tool_input.get("command", "")
    if not command:
        return None

    for seginfo in split_segments(command):
        tokens = tokenize(seginfo["segment"])
        if not tokens:
            continue
        forbidden = match_forbidden(tokens)
        if not forbidden:
            continue
        # Allow grep when part of a pipeline (segment preceded by '|')
        if forbidden["name"] == "grep" and seginfo["separator_before"] == "|":
            continue
        return forbidden
    return None


def get_decision_and_reason(forbidden_command: dict, original_command: str):
    """Return decision type and reason based on command type."""
    name = forbidden_command["name"]
    alt = forbidden_command["alternative"]

    if alt in ("fd", "rg"):
        # Policy enforcement: deny and suggest alternative
        return "deny", f"Use '{alt}' instead of '{name}'"
    else:
        # Manual confirmation required: ask user
        return "ask", f"Confirm: {name}"


def main():
    """Main PreToolUse hook function."""
    try:
        raw_input = sys.stdin.read()
        if not raw_input:
            sys.exit(0)

        try:
            input_data = json.loads(raw_input)
        except json.JSONDecodeError:
            sys.exit(0)

        tool_name = input_data.get("tool_name", "")
        tool_input = input_data.get("tool_input", {})

        forbidden = check_forbidden_bash_commands(tool_name, tool_input)

        if forbidden:
            command = tool_input.get("command", "")
            decision, reason = get_decision_and_reason(forbidden, command)
            
            # Return standard PreToolUse decision control schema
            output = {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": decision,
                    "permissionDecisionReason": reason,
                }
            }
            print(json.dumps(output))
            sys.exit(0)

        sys.exit(0)  # Allow execution

    except Exception as e:
        sys.exit(0)  # Fail open on errors


if __name__ == "__main__":
    main()
