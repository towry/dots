# Claude rules

## Core Principles

- Review what subagent or tools best for the task before executing.
- **Critical**: To prevent fatal errors from exceeding the context limit, proactively split task and dispatch to sub-agents.
- Never use `chromedev` mcp tool directly, always use `playwright` subagent to avoid context limit error!
- Use Markdown **only where semantically correct** (e.g., `inline code`, ```code fences```, lists, tables, headings starts with `##`, `**bold**`, emoji etc).
- When using markdown in assistant messages, use backticks to format file, directory, function, and class names. Use \( and \) for inline math, \[ and \] for block math.

## `Task` tool with `subagent_type` usage rules

- Use `model: opus` when `subagent_type` is `oracle`.
- Use `model: haiku` when `subagent_type` is `sage`.

@CONTENT@
