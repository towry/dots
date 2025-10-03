---
id: hog
title: "Run command with nohup"
model: "google/gemini-2.5-flash"
description: "Run command with nohup and POSIX shell, and run the command in background."
tool_supported: true
subscribe:
    - background
tools:
    - shell
    - fetch
    - read
    - search
    - attempt_completion
custom_rules: |
    - Must use commander-mcp tool to manage the process
---

## Search for the correct command to run in codebase or workspace.

**quick search first**

- Check package manager type, like `pnpm`, `npm`.
- Run shell command `history search pnpm | cat`, familiar with how the command is used.

**deep search**

- Determine the project type, check which package manager is used
- Search for project rules like CLAUDE.md, README.md, .github/instructions/*.md, AGENTS.md for rules that about running commands in current project.
- Search for justfile, Makefile, package.json, etc for available commands.

## command running

Use `commander-mcp` tool to run the command, and read logs, start, restart command.
