# Claude rules

- **Critical**: To prevent fatal errors from exceeding the context limit, proactively use all kind of sub-agent to handle user requests.
- Never use `chromedev` mcp tool directly, always use `playwright` subagent to avoid context limit error!

@CONTENT@
