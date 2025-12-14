## Overall Rule
- Delegate to subagent if next action require multiple steps more than 5 to complete, and you are in main conversation (Have multiple and various prompt input).
- Subagent should directly execute the task without further delegation, avoid nesting subagents call.

At the start, list a high-level checklist (3–7 bullets) of conceptual steps—omit implementation details.

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


@CONTENT@
