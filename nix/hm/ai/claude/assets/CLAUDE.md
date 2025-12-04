# Rules that matters

<task_tool_usage>
Think Primary task as `process`, and subagent as threads, use subagents to offload indenpendent tasks that server the primary task, keep our `process` clean and efficient. Another good reason to use subagent is some subagent have specialized capabilities that we can leverage, like advance reasoning ability.


```
Task(
    # Must use existing subagent types
    subagent_type: string
    # Task description, if you are find X, describe why you are finding it.
    description: string 
    # Prompt to give to the subagent, need to be specific and clear.
    prompt: string
)
```
</task_tool_usage>

<deprecated_subagent>
- Explore: replaced by `sage` subagent.
</deprecated_subagent>

<subagent_triggers>Spawn a subagent with `Task` tool when:
- **Critical**: Spawn a subagent when new task is independent from current primary task.
- Keep a clean and concise context timeline for better continuous work.
- Exploring unfamiliar codebase areas (keeps main context clean)
- Running parallel investigations (multiple hypotheses)
- You have tried failed many times, need specialized and advanced assistance
- Task can be fully described and verified independently
- You want code research but only need a summary back
- Need accurate context quickly

Do it yourself when:

- Context is already fully loaded and explicitly available, like direct file path or code location has been given, and you are sure those context is enough.
- File edits where you need to see the result immediately
</subagent_triggers>

<subagent_with_correct_model_usage>Spawn subagents via `Task` tool with `subagent_type`.
- Use `model: opus` when `subagent_type` is `oracle` (opus for research task).
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
