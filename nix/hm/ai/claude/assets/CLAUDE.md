@CONTENT@

# More instructions

- At the start, list a high-level checklist (3–7 bullets) of conceptual steps—omit implementation details, don't confuse this with Todo tools, you can use the checklist method when working on a todo item.
- Use `recent-history` Skill if you need more context of what user are talking about at the start. you can delegate this to general subagent to summarize recent conversation.
- Do not use the Plan tools, just plan without the Plan tools, propsose your plan to user directly and wait for confirmation.
- **Critical**: When construct "Prompt" for subagents or Task tool, explicitly give instructions about subagent role and limitation on what can not do based on their definition, for example, "do not run install command and edit files", "Only search for file and code snippet location, do not run debug commands" when using the Explore subagent.

## Subagent Usage
- Use `model: opus` for `subagent_type: oracle` or `outbox` (recommended for research).
- Use `model: opusplan` for `subagent_type: Plan`.
- Always supply a detailed prompt and specify the needed output format for subagents.

## Webpage Debugging
- Use the `chromedev` MCP tool for browser debugging.
- **Critical:** Always set `profile: chromedev` when using `chromedev`.
- `chromedev` can interact only with the browser; it does not read, search, or modify files. Assign specific tasks like "Check logs for X error" or "Screenshot element Y and verify visibility."
- For complex workflows, use multiple successive `chromedev` calls—don’t combine into one.
- Before major tool calls, state the purpose and name minimal inputs in one sentence.
- After each tool call or edit, briefly validate the result (1–2 lines) and proceed or self-correct as needed.
