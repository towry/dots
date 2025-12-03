# Rules that matters

<session_start>
- Analyze next action complex, spawn subagent with `Task` tool when necessary to keep main context clean, leverage claude skills for better task handling.
- If the task is about to search code in codebase, consider spawn multiple `sage` subagent in parallel to help you speed up the process.
- If the task is about to use kg to search memory, consider spawn `sage` subagent to avoid context bloat.
- If the task is about web search, github issues search, consider spawn multiple `eng` subagent in parallel to speed up the research.
</session_start>

<subagent_triggers>Spawn a subagent with `Task` tool when:
- Exploring unfamiliar codebase areas (keeps main context clean)
- Running parallel investigations (multiple hypotheses)
- Task can be fully described and verified independently
- You want code research but only need a summary back

Do it yourself when:

- Task is very simple and sequential, can be done in 1 ~ 2 steps
- Context is already loaded and explictly available, like direct file path or code location has been given
- File edits where you need to see the result immediately </subagent_triggers>

<search_code_with_sage_subagent>When to use `sage` subagent.
- Try to search for some code in codebase.
- Simple or multiple step codebase exploration.
- When you about to say `Let me search for the ...`
</search_code_with_sage_subagent>

<errand_tasks_with_coding_web_search_abilities>When to use `eng` subagent. 
- Small or quick coding tasks with explicit implementation instructions
- External resources research from web, github, knowledge graph, provide comprehensive research output
</errand_tasks_with_coding_web_search_abilities>

<subagent_oracle_trigger> When to use `oracle` subagent.
- Architecture decisions with multiple valid approaches
- Debugging gnarly issues after initial attempts fail
- Planning multi-file refactors before touching code
- Reviewing complex PRs or understanding unfamiliar code
- Any time you're about to do something irreversible
- User want a comprehensive or better research on a topic
</subagent_oracle_trigger>

<subagent_outbox_trigger>When to use `outbox` subagent.
- Generating multiple ideas or solutions for a problem
- Reframing a problem from different perspectives
- Brainstorming pros and cons of various approaches
- Seeking alternative viewpoints on a proposed plan
- When you feel stuck and need fresh inspiration
- You have a comprehensive analysis and plan, but want to explore more options or second opinions before proceeding
</subagent_outbox_trigger>

<subagent_with_correct_model_usage>`Task` tool with `subagent_type` usage rules
- Use `model: opus` when `subagent_type` is `oracle` (opus for research task).
- Use `model: haiku` when `subagent_type` is `sage`(code search agent).
- Use `model: haiku` when `subagent_type` is `eng` (light coding task agent).
- Use `model: opusplan` when `subagent_type` is `Plan` (plan agent).
</subagent_with_correct_model_usage>

<webpage_debug>
- Use `codex_chromedev` mcp tool to debug webpage with page url.
- **critical**: Always use `profile: chromedev` when using `codex_chromedev` tool.
- chromedev only support browser interactions, it can not read or search files. So You need give it specfic task like "What is the logs that related to X eror?" or "Take screenshot of element Y check if it is visible".
- Call chromedev in multiple iterations if necessary to accomplish the task, don't try to do everything in one call.
</webpage_debug>

@CONTENT@
