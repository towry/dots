CLAUDE HOOKS — Quick Reference & Cookbook
========================================

This document explains how to create, test, and maintain Claude Code hooks in your project.
It covers common hook events, input/output schemas, examples, and best practices to make robust and secure hooks.

Contents
--------
- Introduction
- Hook types & when they run
- Hook input schema (common fields)
- Hook output behavior and decision control
- Common environment variables available to hooks
- Creating a hook: shell + Python examples
- Example: SessionStart (session_remind.py)
- Example: SubagentStop & resume (subagent_remind.py + get_last_agent.py)
- Testing hooks locally
- Logging, security & privacy
- Troubleshooting & tips

Introduction
------------
Claude Code hooks let you run scripts on CLI/certain events to add automation, validation, or context for your session.
Hooks can be scripts (type: "command") or prompt-based (type: "prompt"). The CLI passes JSON to your script via stdin — use it to decide action.

Hook types & when they run
-------------------------
- PreToolUse — Runs just before a tool call. Useful to approve, deny, or modify tool inputs.
- PostToolUse — Runs right after a tool completes (can provide feedback).
- Notification — Runs on notifications (e.g., permission prompts).
- UserPromptSubmit — Runs when a user submits a prompt (stdin is the prompt JSON).
- SessionStart — Runs when a session starts or resumes. Use it to inject context or set environment variables.
- SessionEnd — Runs when a session ends.
- PreCompact — Runs before the CLI compacts a transcript (automatic or manual compaction).
- Stop / SubagentStop — Run when the main agent or a subagent stops. SubagentStop is used to capture a subagent tool result.

Hook input schema (common fields)
---------------------------------
Hooks receive a JSON object via stdin. Common fields (present on all events):
- session_id: string
- transcript_path: path to a JSONL transcript for the session
- cwd: current working directory for the hook execution
- permission_mode: "default"|"plan"|"acceptEdits"|"bypassPermissions"
- hook_event_name: the event name string

Event-specific fields are described in the official docs but tools often include:
- tool_name, tool_input, tool_response, toolUseResult, stop_hook_active, source, trigger, etc.

Hook output behavior and decision control
----------------------------------------
There are two main ways to interact:
1. Exit codes (0 success, 2 block — behavior depends on the hook event)
2. JSON stdout (advanced responses) — export `hookSpecificOutput` and other fields like `continue`, `stopReason`.

Special case: `stdout` is injected into the context for `UserPromptSubmit` and `SessionStart`. That makes it a simple way to add context for the agent.

Examples of JSON output that control behavior:
```json
{
  "hookSpecificOutput": { "hookEventName": "UserPromptSubmit", "additionalContext": "My context string" }
}
```

Common environment variables available to hooks
---------------------------------------------
- CLAUDE_PROJECT_DIR: Absolute path to the current project root (when running project hooks)
- CLAUDE_TRANSCRIPT_PATH: Path to the session's transcript file (when available)
- CLAUDE_ENV_FILE: (SessionStart only) a file path to append exported env vars for future commands
- CLAUDE_CODE_REMOTE: if running in remote environment

Creating a hook: shell + Python examples
---------------------------------------
General structure for a command hook:

1) Write a standalone executable script under `.claude/hooks/` — either shell or Python
2) Make sure the script consumes JSON from stdin and exits gracefully
3) Register your hook in `.claude/settings.json` under the `hooks` map

Example bash hook (print session id) — exits 0 on success:
```bash
#!/usr/bin/env bash
set -euo pipefail
if [ -t 0 ]; then exit 0; fi
stdin=$(cat)
session_id=$(echo "$stdin" | jq -r '.session_id // empty')
if [ -n "$session_id" ]; then
  jq -n --arg sid "$session_id" '{"hookSpecificOutput": {"hookEventName":"SessionStart","additionalContext":"Session ID: \($sid)"}}'
fi
```

Example Python hook snippet (read JSON and print JSON output):
```python
import json, sys
input_data = json.loads(sys.stdin.read())
sid = input_data.get('session_id')
if sid:
    out = {"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": f"Sess {sid}"}}
    print(json.dumps(out))
    sys.exit(0)
```

Example: SessionStart — `session_remind.py` (why it’s useful)
---------------------------------------------------------
Purpose: Add session id and project dir to the session context so that subsequent tools/agents can use it. Useful for debugging or for small automated tasks that need session awareness.

Key points:
- Use `CLAUDE_PROJECT_DIR` first when available, fallback to `cwd` from input
- Log the event to `.claude/logs/session_start.json` for auditing
- Add context with `hookSpecificOutput.additionalContext` so it appears in the session (SessionStart and UserPromptSubmit inject stdout into context)

Example config snippet in `.claude/settings.json` to run script on SessionStart:
```jsonc
"hooks": {
   "SessionStart": [
     { "matcher": "", "hooks": [ { "type": "command", "command": "uv run ~/.claude/hooks/session_remind.py" } ] }
   ]
}
```

Example: SubagentStop & resume (limitations & workaround)
---------------------------------------------------------
The Task tool may start a subagent; sometimes it emits an `agentId` in `toolUseResult`. However, SubagentStop's stdout is _not_ forwarded to the parent agent as injected context. This prevents a parent from directly resuming a subagent via a hook result.

Workaround: Use `SubagentStop` hook to extract `agentId` and write it to a file under the project (e.g., `<project>/.claude/logs/last_agent_id_<session>.txt`). Then use a `UserPromptSubmit` hook to read that file and inject the `agentId` into the parent session via `additionalContext`.

Files and flow:
1. `subagent_remind.py` (exc extract, log, and write last_agent_id to `.claude/logs/last_agent_id_<session>.txt`)
2. `get_last_agent.py` reads the file and prints `hookSpecificOutput` on `UserPromptSubmit`.
  If the per-session file isn't present, `get_last_agent.py` will fall back to the newest
  `last_agent_id_*.txt` file in `<project>/.claude/logs/` to provide a sensible agent id to the
  parent prompt.
  Additionally, `get_last_agent.py` will scan the session transcript for recent `toolUseResult.agentId` entries when no last_agent file exists — this helps in cases where the SubagentStop hook didn't run or the file wasn't written due to race conditions.
3. The parent can now pick up the agent ID and call `Task tool` with `resume`.

This workaround is robust (doesn't rely on a feature in the runtime) and respects project boundaries if you use `CLAUDE_PROJECT_DIR` and proper file permissions.

Testing hooks locally
---------------------
You can test any hook by piping JSON into the script. Example:
```bash
printf '{"session_id":"abc123","cwd":"/path/to/project","hook_event_name":"SessionStart","source":"startup"}' | python3 ./.claude/hooks/session_remind.py --verbose
```
Look for:
- JSON print returning `hookSpecificOutput` in stdout
- New entries in `.claude/logs/...` as written by your script

Testing a SubagentStop flow:
1. Run the SubagentStop script with an input that contains `toolUseResult.agentId` (and `cwd` pointing to your project):
```bash
printf '{"session_id":"abc123","cwd":"/path/to/project","hook_event_name":"SubagentStop","toolUseResult":{"agentId":"a123"}}' | python3 ./.claude/hooks/subagent_remind.py --verbose
```
2. Verify that: `.claude/logs/last_agent_id_abc123.txt` exists and contains `a123`.
3. Run the UserPromptSubmit hook to verify it injects additionalContext (simulate the parent submitting a prompt):
```bash
printf '{"session_id":"abc123","hook_event_name":"UserPromptSubmit","cwd":"/path/to/project"}' | python3 ./.claude/hooks/get_last_agent.py --verbose
```
Debugging hooks
----------------
Debug logging is enabled by default. If the hook doesn't behave as expected, you can disable debug logging by passing `--no-debug` or set `CLAUDE_HOOK_DEBUG=0` to turn it off. The hooks write a JSONL debug file to `<project>/.claude/logs/`:

- `subagent_remind_debug_<session>.jsonl` — detailed entries about transcript extraction attempts and write operations
- `get_last_agent_debug_<session>.jsonl` — fallback decisions and file selection

These logs are appended in chronological order and include timestamps and structured fields to make it easy to inspect program execution. Use `jq` to read them safely:

```bash
jq -c '.' <project>/.claude/logs/subagent_remind_debug_<session>.jsonl | sed -n '1,100p'
```
Notes:
- The script supports both `--quiet` (disable verbose prints) and `--verbose` flags. By default the script prints a small diagnostic message unless `--quiet` is provided.

Logging, security & privacy
---------------------------
1. Do NOT log sensitive values such as secrets, API keys, or environment variables.
2. If you write logs to the project, ensure they're in `.gitignore` (don't push them to version control):
   Add: `.claude/logs/` to `.gitignore`.
3. Use filesystem permissions to restrict access to log files: `chmod 600`.
4. If you need to retain logs for debugging, add rotation/cleanup logic (e.g., age-based deletion).

**Agent ID Validation (Critical):**
5. When extracting agent IDs, ONLY trust `toolUseResult.agentId` fields.
6. Validate agent IDs match the expected format (8 hex characters: `^[0-9a-fA-F]{8}$`).
7. DO NOT use regex to extract IDs from arbitrary strings - transcripts contain many IDs (leafUuid, message uuid, sessionId) that will cause false positives and data corruption.
8. If an agent ID doesn't match the format, reject it to prevent using session IDs or other UUIDs as agent IDs.

Troubleshooting & tips
----------------------
- Hooks are read at session startup. If you change `settings.json` you often must re-open the session or restart the CLI.
- If your script is not running:
  - Validate `settings.json` is valid JSON.
  - Check that `disableAllHooks` is `false`.
  - Confirm `matcher` matches or is blank for non-matcher events.
  - Use `--verbose` in scripts for additional prints.
  - Use `claude --debug` or `claude --verbose` to inspect runtime hook execution details.
- Test locally with `printf ... | python3 path/to/script.py` to verify the script quickly.

Best practices
--------------
- Prefer `CLAUDE_PROJECT_DIR` over `cwd` for files written to the project.
- Make hooks idempotent and fail-safe — they should not block the CLI unless you intend to (exit code 2).
- Avoid side effects that may be irreversible; write logs to `.claude/logs` and not to root directories.
- Keep hooks small and single-purpose; use helper scripts for complex work.
- Use `--verbose` flags and add `DEBUG` guard clauses to limit output to testing only.

If you’d like, I can:
1. Add a `hooks/README.md` with a short checklist and sample settings.json entries.
2. Add a CLI script that validates hook scripts and settings.json in a repo.
3. Add a small test harness that uses the `printf|python` pattern used above to validate hooks in CI.

End — happy to expand any of these sections or create small runnable examples in `.claude/hooks/` (some are already present in this repo).
