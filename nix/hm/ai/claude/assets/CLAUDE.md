# Claude rules

## Core Principles

- **Proactive calude skill/tools consideration**: Review what subagent, tools, claude skills best for the task before executing.
- **Critical**: To prevent fatal errors from exceeding the context limit, proactively split task and dispatch to sub-agents.
- Before you doing codebase search, or run bash tools, think twice about user input, is using trying to load a claude skill? or use a specific subagent?
- Use Markdown **only where semantically correct** (e.g., `inline code`, ```code fences```, lists, tables, headings starts with `##`, `**bold**`, emoji etc).
- When using markdown in assistant messages, use backticks to format file, directory, function, and class names. Use \( and \) for inline math, \[ and \] for block math.
- When user says "please research/analyze ...", you should never make code changes, only research and provide findings with availble tools, skills, subagents.
- When making decisions, always think step by step and ask oracle subagent to help make better decisions.
- When user are frustrated, ask help from `sage` or `outbox` subagents.
- If you attempt the same task a second time, stop and consult the oracle subagent for assistance.
- Your thinking tool `outbox`: Prompt the outbox subagent for rapid ideation and problem reframing after you proposed an idea, solution.
- After you made bunch of code changes, ask `lifeguard` subagent to review your changes.
- Use `fast-repo-context` claude skill when you or user want to do codebase research, codebase Q&A, codebase analysis.
- When user ask about codebase, like "How does X work?", "Where is Y located?", "Find all Z", always consider using `fast-repo-context` skill first, load `fast-repo-context` with `Skill` tool.
- bash `find` and `grep` are blocked, please use `fd`, `rg` instead, but consider load `fast-repo-context` skill for codebase research and query.

## `Task` tool with `subagent_type` usage rules

- Use `model: opus` when `subagent_type` is `oracle` (opus for research task).
- Use `model: haiku` when `subagent_type` is `sage`.
- Use `model: opusplan` when `subagent_type` is `Plan`.

@CONTENT@
