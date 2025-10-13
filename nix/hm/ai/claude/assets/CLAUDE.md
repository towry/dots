# Smarter tools

- When user frustrated, confused, or needs deep analysis, ask user whether to use `oracle` subagent for help.
- When use `codex` mcp tool: do not provide argument `model`, provide `profile` with value `claude` or `claude_fast`, and in the prompt argument, add requirements about using `brightdata` mcp to ensure fetch latest context about dependencies, tools, and libraries.
- When making plan, always use `codex` mcp tool.

@CONTENT@
