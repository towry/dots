# Rules that matters

<external_research>
What: External research refer to research from web, you need context from the web, online doc, github etc.
When: You need to debug issues that related to third library, seeking answers to issue from the web like github issues or stackoverflow.
How: Use `eng` subagent to do the external research for you.
</external_research>

<subagent_triggers>
- Do not call subagent in subagent
- Keep a clean and concise context timeline for better continuous work.
- Exploring unfamiliar codebase areas (keeps main context clean)
- Running parallel investigations (multiple hypotheses)
- Despite multiple (max 3 times) attempts, you were unable to succeed. Consider seeking assistance from other subagents.
- Task can be fully described and verified independently
- You want code research but only need a summary back
- Need accurate context quickly
- You need to do external research from web or github

Do it yourself when:

- Never spawn subagent inside another subagent, this will lead to memory overflow.
- **Pre-loaded context**: You're responding to a direct question about
code/files already visible in this conversation, and no additional research is
  needed
- **Immediate edits**: Making small, reversible changes that don't require
research or commit operations (e.g., fixing typos, updating comments, quick
refactors)
- **Simple operations**: Tasks that can be completed in under 2 minutes
without external research or complex coordination

</subagent_triggers>

<subagent_with_correct_model_usage>Spawn subagents via `Task` tool with `subagent_type`.
- Use `model: opus` when `subagent_type` is `oracle` (opus for research task).
- Use `model: opus` when `subagent_type` is `outbox` (opus for research task).
- Use `model: sonnet` when `subagent_type` is `sage`(code search agent).
- Use `model: sonnet` when `subagent_type` is `eng` (light coding task agent).
- Use `model: sonnet` when `subagent_type` is `ford` (helper on tool and subagent use).
- Use `model: opusplan` when `subagent_type` is `Plan` (plan agent).
</subagent_with_correct_model_usage>

<webpage_debug>
- Use `debug_webpage` mcp tool to debug webpage in browser.
- **critical**: Always use `profile: chromedev` when using `debug_webpage` tool.
- chromedev only support browser interactions, it can not read, search files, or edit files. So You need give it specific task like "What is the logs that related to X error?" or "Take screenshot of element Y check if it is visible".
- Call chromedev in multiple iterations if necessary to accomplish the task, don't try to do everything in one call.
</webpage_debug>

@CONTENT@
