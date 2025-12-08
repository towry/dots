# Rules that matters

<task_tool_usage>
- Think current as `process`, and subagent as threads, use subagents to offload independent task that server the `process`, keep our `process` clean and efficient. Another good reason to use subagent is some subagent have specialized capabilities that we can leverage, like advance reasoning ability.
- If a task can be divided into multiple stages, like first code search, then code implementation analysis. Delegate each stage to subagents. Execute the stages sequentially if they have dependencies, or run them in parallel if they are independent. For example, first use sage to identify relevant code location, **then** use eng to analyze implementation details. Always make sure each subagent task focus on one specific goal.
- **Critical**: Right subagent for right task, check the Task tool schema and use the correct subagent type for your task.
- subagent like computer threads does not know current or parent context, so do not assume they have any context, always provide necessary context in the prompt, with explicit instructions on what to do and what the expect output is.



```
# Only list required parameters
Task(
    # Must use existing subagent types
    subagent_type
    # Task description, if you are find X, describe why you are finding it.
    description
    # Prompt to give to the subagent, need to be specific and clear.
    prompt
)
```
</task_tool_usage>

<external_research>
What: External research refer to research from web, you need context from the web, online doc, github etc.
When: You need to debug issues that related to third library, seeking answers to issue from the web like github issues or stackoverflow.
How: Use `eng` subagent to do the external research for you.
</external_research>

<subagent_triggers>Spawn a subagent with `Task` tool when:
- **Critical**: Spawn a subagent when new task is independent from current primary task.
- Keep a clean and concise context timeline for better continuous work.
- Exploring unfamiliar codebase areas (keeps main context clean)
- Running parallel investigations (multiple hypotheses)
- Despite multiple (max 3 times) attempts, you were unable to succeed. Consider seeking assistance from other subagents.
- Task can be fully described and verified independently
- You want code research but only need a summary back
- Need accurate context quickly
- You need to do external research from web or github

Do it yourself when:

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
- Use `model: haiku` when `subagent_type` is `sage`(code search agent).
- Use `model: haiku` when `subagent_type` is `eng` (light coding task agent).
- Use `model: opusplan` when `subagent_type` is `Plan` (plan agent).
</subagent_with_correct_model_usage>

<webpage_debug>
- Use `codex_chromedev` mcp tool to debug webpage with page url.
- **critical**: Always use `profile: chromedev` when using `codex_chromedev` tool.
- chromedev only support browser interactions, it can not read or search files. So You need give it specific task like "What is the logs that related to X error?" or "Take screenshot of element Y check if it is visible".
- Call chromedev in multiple iterations if necessary to accomplish the task, don't try to do everything in one call.
</webpage_debug>

@CONTENT@
