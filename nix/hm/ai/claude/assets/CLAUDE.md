# Claude rules

## Core Principles

- Review what subagent, tools, skills best for the task before executing.
- **Critical**: To prevent fatal errors from exceeding the context limit, proactively split task and dispatch to sub-agents.
- Use Markdown **only where semantically correct** (e.g., `inline code`, ```code fences```, lists, tables, headings starts with `##`, `**bold**`, emoji etc).
- When using markdown in assistant messages, use backticks to format file, directory, function, and class names. Use \( and \) for inline math, \[ and \] for block math.
- When user says "please research ...", you should never make code changes, only research and provide findings with availble tools, skills, subagents.
- When making decisions, always think step by step and ask oracle subagent to help make better decisions.
- If you attempt the same task a second time, stop and consult the oracle subagent for assistance.
- Your thinking tool `outbox`: Prompt the outbox subagent for rapid ideation and problem reframing after you proposed an idea, solution.

## `Task` tool with `subagent_type` usage rules

- Use `model: opus` when `subagent_type` is `oracle` (opus for research task).
- Use `model: haiku` when `subagent_type` is `sage`.

@CONTENT@
