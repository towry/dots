# Rules that matters

<subagent_triggers>Spawn a subagent with `Task` tool when:
- Exploring unfamiliar codebase areas (keeps main context clean)
- Running parallel investigations (multiple hypotheses)
- Task can be fully described and verified independently
- You want code research but only need a summary back

Do it yourself when:

- Task is very simple and sequential, can be done in 1 ~ 2 steps
- Context is already loaded and explictly available, like direct file path or code location has been given
- File edits where you need to see the result immediately </subagent_triggers>

<subagent_sage_trigger>When to use `sage` subagent.
- Try to understand unfamiliar code in local codebase.
- Try to find location of specific function, class, variable, or file in codebase.
- When user asks "How does X work?" about codebase.
- When user asks "What files are related to Y?" about codebase.
</subagent_sage_trigger>

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
</subagent_outbox_trigger>

<subagent_with_correct_model_usage>`Task` tool with `subagent_type` usage rules
- Use `model: opus` when `subagent_type` is `oracle` (opus for research task).
- Use `model: haiku` when `subagent_type` is `sage`(code search agent).
- Use `model: haiku` when `subagent_type` is `eng` (light coding task agent).
- Use `model: opusplan` when `subagent_type` is `Plan` (plan agent).
</subagent_with_correct_model_usage>

@CONTENT@
