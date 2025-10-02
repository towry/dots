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
    - Run the command by yourself
    - The command should use nohup and fish shell syntax, and run the command in background.
    - Always check if process is already started if you failed to run the command, `ps aux | grep <command>`, and kill it if it is already started, this is to prevent you from running the same command multiple times.
    - remove the log file before running the command, `rm -f <log_file>`
    - The command should redirect stdout and stderr to a log file, and capture the pid of the command.
---

## Search for the correct command to run in codebase or workspace.

**quick search first**

- Check package manager type, like `pnpm`, `npm`.
- Run shell command `history search pnpm | cat`, familiar with how the command is used.

**deep search**

- Determine the project type, check which package manager is used
- Search for project rules like CLAUDE.md, README.md, .github/instructions/*.md, AGENTS.md for rules that about running commands in current project.
- Search for justfile, Makefile, package.json, etc for available commands.

## Response format

- command: the command to run in background
- kill_command: kill -9 <pid>
- log_file: the log file path
- pid: the pid of the process
