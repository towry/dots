#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "python-dotenv",
# ]
# ///

"""PreToolUse hook to block forbidden Bash commands and suggest alternatives.

This hook runs before any tool is executed and can block execution.
It specifically blocks:
- Bash tool calls with commands containing 'find' -> suggests using 'fd' instead
- Bash tool calls with commands containing 'grep' -> suggests using 'rg' instead

The hook exits with code 2 to block execution when forbidden commands are detected.
"""

import argparse
import json
import re
import sys


def check_forbidden_bash_commands(tool_name: str, tool_input: dict):
    """Check if tool input contains forbidden Bash commands."""
    if tool_name != "Bash":
        return None

    # Get the command from tool input
    command = tool_input.get("command", "")
    if not command:
        return None

    # Check for forbidden commands (case insensitive)
    forbidden_patterns = [
        {
            "name": "find",
            "pattern": r"\bfind\b",
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
            "name": "grep",
            "pattern": r"\bgrep\b",
            "alternative": "rg",
            "examples": [
                'rg "TODO"                         # Search for TODO in all files',
                'rg -tpy "import"                  # Search only in Python files',
                'rg -tjs "useState"                # Search only in JavaScript files',
                'rg --glob "*.md" "# Heading"        # Search only in markdown files',
                'rg -C 2 "error"                  # Show 2 lines of context',
                'rg -i "error"                      # Case-insensitive search',
            ],
            "benefits": "",
        },
        {
            "name": "jj git init",
            "pattern": r"\bjj\s+git\s+init\b",
            "alternative": "ask user to run it",
            "examples": [
                "User, please initialize the jj git repo.",
            ],
            "benefits": "Prevents accidental jj repo creation",
        },
        {
            "name": "jj git push",
            "pattern": r"\bjj\s+git\s+push\b",
            "alternative": "ask user to run it",
            "examples": [
                "User, please push the changes with jj.",
            ],
            "benefits": "Prevents accidental jj pushes",
        },
        {
            "name": "git init",
            "pattern": r"\bgit\s+init\b",
            "alternative": "ask user to run it",
            "examples": [
                "User, please initialize the git repository.",
            ],
            "benefits": "Prevents accidental repo creation",
        },
        {
            "name": "git push",
            "pattern": r"\bgit\s+push\b",
            "alternative": "ask user to run it",
            "examples": [
                "User, please push the changes.",
            ],
            "benefits": "Prevents accidental pushes",
        },
        {
            "name": "git clean",
            "pattern": r"\bgit\s+clean\b",
            "alternative": "ask user to run it",
            "examples": [
                "User, please clean the repository.",
            ],
            "benefits": "Prevents accidental deletion of untracked files",
        },
    ]

    for forbidden in forbidden_patterns:
        if re.search(forbidden["pattern"], command, re.IGNORECASE):
            return forbidden

    return None


def generate_help_message(forbidden_command: dict, original_command: str):
    """Generate helpful message about the blocked command."""
    name = forbidden_command["name"]
    alt = forbidden_command["alternative"]

    message = [
        f"🚫 Command blocked: 'Bash({name})' detected",
        "",
        f"💡 Use '{alt}' instead - a better, faster alternative",
        "",
        f"❌ You tried: Bash({original_command})"
        if len(original_command) < 50
        else f"❌ You tried: Bash({original_command[:47]}...)",
        f"✅ Better: {alt} [options] [pattern]",
        "",
        f"📚 Examples with {alt}:",
    ]

    for example in forbidden_command["examples"]:
        message.append(f"   {example}")

    message.extend(
        [
            "",
            f"💡 To continue, replace your Bash({name}) call with appropriate {alt} command.",
        ]
    )

    if alt in ["fd", "rg"]:
        message.extend(
            [
                "",
                f"📖 Common {alt} options:",
                "   fd: --hidden, --no-ignore, -e [ext], -d [depth], -i",
                "   rg: -t[type], --glob, -C [lines], -i, --no-ignore",
            ]
        )

    return "\n".join(message)


def main():
    """Main PreToolUse hook function."""
    try:
        parser = argparse.ArgumentParser(
            description="PreToolUse hook to block forbidden Bash commands"
        )
        parser.add_argument(
            "--verbose",
            action="store_true",
            help="Print detailed information about why command was blocked",
        )
        args = parser.parse_args()

        # Read JSON input from stdin
        raw_input = sys.stdin.read()
        if not raw_input:
            sys.exit(0)

        try:
            input_data = json.loads(raw_input)
        except json.JSONDecodeError:
            sys.exit(0)

        # Extract tool information
        tool_name = input_data.get("tool_name", "")
        tool_input = input_data.get("tool_input", {})

        # Check for forbidden commands
        forbidden = check_forbidden_bash_commands(tool_name, tool_input)

        if forbidden:
            # Generate and display help message
            command = tool_input.get("command", "")
            help_message = generate_help_message(forbidden, command)

            print("\n" + "=" * 80, file=sys.stderr)
            print(help_message, file=sys.stderr)
            print("=" * 80 + "\n", file=sys.stderr)

            if args.verbose:
                print(f"[DEBUG] Tool: {tool_name}", file=sys.stderr)
                print(f"[DEBUG] Command: {command}", file=sys.stderr)
                print(f"[DEBUG] Pattern matched: {forbidden['pattern']}", file=sys.stderr)
                print(f"[DEBUG] Suggested alternative: {forbidden['alternative']}\n", file=sys.stderr)

            # Block execution by exiting with code 2
            sys.exit(2)

        # Allow execution (exit code 0)
        sys.exit(0)

    except Exception as e:
        # On any error, allow execution to proceed
        # This prevents the hook from breaking Claude if there's a bug
        if "args" in locals() and args.verbose:
            print(f"Hook error: {e}", file=sys.stderr)
        sys.exit(0)


if __name__ == "__main__":
    main()

