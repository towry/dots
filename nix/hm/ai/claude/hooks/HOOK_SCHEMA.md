# Claude CLI Hook Schema Documentation

## Overview

Claude CLI hooks are scripts that can intercept and modify various events during Claude's execution. Hooks receive JSON input via stdin and must output valid JSON to stdout.

## Common Hook Output Schema

All hooks must return a JSON object with the following optional fields:

```json
{
  "continue": boolean (optional),
  "suppressOutput": boolean (optional),
  "stopReason": string (optional),
  "decision": "approve" | "block" (optional),
  "reason": string (optional),
  "systemMessage": string (optional),
  "permissionDecision": "allow" | "deny" | "ask" (optional),
  "hookSpecificOutput": { ... }
}
```

### Common Fields

- **`continue`**: Whether to continue execution (default: true)
- **`suppressOutput`**: Whether to suppress the hook's output from being shown to the user
- **`stopReason`**: Reason for stopping execution (if `continue: false`)
- **`decision`**: `"approve"` or `"block"` - controls whether the action proceeds
- **`reason`**: Human-readable explanation shown to the user
- **`systemMessage`**: Additional system message to display
- **`permissionDecision`**: `"allow"`, `"deny"`, or `"ask"` - permission decision

---

## Hook Types

### 1. UserPromptSubmit

Intercepts user prompts before they are sent to Claude.

#### Input (stdin)

```json
{
  "prompt": "string - The user's input",
  "cwd": "string - Current working directory",
  "transcript_path": "string - Path to session transcript"
}
```

#### Output (stdout)

```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "string (required) - Context to append to the prompt"
  }
}
```

**Note**: `additionalContext` is **required** for UserPromptSubmit hooks.

#### Example: Adding Context

```python
output = {
    "hookSpecificOutput": {
        "hookEventName": "UserPromptSubmit",
        "additionalContext": "Available tools: git, npm, cargo"
    }
}
print(json.dumps(output))
```

#### Example: Blocking a Prompt

```python
output = {
    "decision": "block",
    "reason": "This command is not allowed",
    "hookSpecificOutput": {
        "hookEventName": "UserPromptSubmit"
    }
}
print(json.dumps(output))
```

---

### 2. PreToolUse

Intercepts tool calls before execution.

#### Input (stdin)

```json
{
  "tool": "string - Tool name (e.g., 'Bash', 'Read', 'Write')",
  "input": "object - Tool input parameters",
  "cwd": "string - Current working directory"
}
```

#### Output (stdout)

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow" | "deny" | "ask" (optional),
    "permissionDecisionReason": "string (optional)",
    "updatedInput": "object (optional) - Modified tool input"
  }
}
```

#### Example: Blocking a Bash Command

```python
output = {
    "decision": "block",
    "reason": "rm -rf commands are forbidden",
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": "Destructive command detected"
    }
}
print(json.dumps(output))
```

#### Example: Modifying Tool Input

```python
output = {
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "updatedInput": {
            "command": "git status --short"  # Modified command
        }
    }
}
print(json.dumps(output))
```

---

### 3. PostToolUse

Intercepts tool results after execution.

#### Input (stdin)

```json
{
  "tool": "string - Tool name",
  "input": "object - Tool input that was used",
  "output": "string - Tool output/result",
  "cwd": "string - Current working directory"
}
```

#### Output (stdout)

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "string (optional) - Context to add after tool execution"
  }
}
```

#### Example: Adding Context After Tool Use

```python
output = {
    "hookSpecificOutput": {
        "hookEventName": "PostToolUse",
        "additionalContext": "Remember to check test results"
    }
}
print(json.dumps(output))
```

---

### 4. PreCompact

Called before compacting the conversation history.

#### Input (stdin)

```json
{
  "messageCount": number,
  "cwd": "string"
}
```

#### Output (stdout)

Standard hook output format. Use `decision: "block"` to prevent compaction.

---

### 5. SessionStart

Called when a new Claude session starts.

#### Input (stdin)

```json
{
  "cwd": "string - Current working directory",
  "sessionId": "string - Session identifier"
}
```

#### Output (stdout)

```json
{
  "hookSpecificOutput": {
    "additionalContext": "string (optional) - Context to show at session start"
  }
}
```

---

### 6. SubagentStop

Called when a subagent (Task tool) completes.

#### Input (stdin)

```json
{
  "agentId": "string - Subagent identifier",
  "result": "string - Subagent result",
  "cwd": "string"
}
```

#### Output (stdout)

```json
{
  "hookSpecificOutput": {
    "additionalContext": "string (optional) - Context to add after subagent"
  }
}
```

---

### 7. Notification

Called when Claude needs to notify the user.

#### Input (stdin)

```json
{
  "message": "string - Notification message",
  "type": "string - Notification type"
}
```

#### Output (stdout)

Standard hook output format.

---

## Hook Configuration

Hooks are configured in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "uv run ~/.claude/hooks/my_hook.py"
          }
        ]
      }
    ]
  }
}
```

### Hook Execution Order

Hooks in the same array are executed in order. If a hook blocks execution (`decision: "block"`), subsequent hooks in the array are not executed.

### Matcher Field

The `matcher` field allows filtering which events trigger the hook:
- Empty string `""`: Matches all events
- For PreToolUse: Tool name (e.g., `"Bash"`, `"Read"`)
- For other hooks: Custom pattern matching

---

## Best Practices

### Exit Codes

- **Exit 0**: Hook succeeded
- **Non-zero exit**: Hook failed (error is logged, execution continues)

### Error Handling

Always handle JSON parsing errors:

```python
try:
    input_data = json.load(sys.stdin)
except json.JSONDecodeError as e:
    print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
    sys.exit(1)
```

### Performance

- Keep hooks fast (< 100ms when possible)
- Avoid network calls unless necessary
- Cache expensive computations

### Debugging

Log to stderr for debugging (won't affect JSON output):

```python
print(f"Debug: Processing prompt: {prompt}", file=sys.stderr)
```

### Required vs Optional Fields

- **UserPromptSubmit**: `additionalContext` is **required** in `hookSpecificOutput`
- **PreToolUse**: All fields in `hookSpecificOutput` are optional
- **PostToolUse**: `additionalContext` is optional

---

## Example Hooks

### Block Dangerous Commands

```python
#!/usr/bin/env python3
import json
import sys

input_data = json.load(sys.stdin)
tool_input = input_data.get("input", {})
command = tool_input.get("command", "")

if "rm -rf /" in command:
    output = {
        "decision": "block",
        "reason": "Dangerous command blocked",
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny"
        }
    }
    print(json.dumps(output))
    sys.exit(0)
```

### Add Project Context on Session Start

```python
#!/usr/bin/env python3
import json
import sys
from pathlib import Path

input_data = json.load(sys.stdin)
cwd = Path(input_data.get("cwd", "."))

# Read project README
readme = cwd / "README.md"
context = ""
if readme.exists():
    context = f"Project README:\n{readme.read_text()[:500]}..."

output = {
    "hookSpecificOutput": {
        "additionalContext": context
    }
}
print(json.dumps(output))
```

---

## Troubleshooting

### "JSON validation failed" Error

This means your hook's output doesn't match the expected schema:

1. Check that `hookEventName` matches the hook type exactly
2. For UserPromptSubmit: Ensure `additionalContext` is present
3. Verify all field names are spelled correctly
4. Ensure you're outputting valid JSON to stdout

### Hook Not Running

1. Check `disableAllHooks` is not `true` in settings.json
2. Verify hook script is executable (`chmod +x`)
3. Check hook command path is correct
4. Look for errors in Claude's output

### Hook Runs But Does Nothing

1. Verify you're printing to stdout (not stderr)
2. Check exit code is 0
3. Ensure JSON is valid: `python3 hook.py < test.json | jq`
