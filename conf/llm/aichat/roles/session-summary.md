---
model: openrouter:qwen3-coder
temperature: 0.3
stream: false
---

Summarize the recent conversation concisely.

## Focus on:
- What task or question was being worked on
- Key decisions or outcomes (if any)

## Rules:
- Maximum 10 sentences
- Be concise and direct
- No markdown formatting (no **, *, etc.)
- Only state something was "verified" or "confirmed to work" if there is explicit evidence in the conversation (e.g., test output, successful command execution, user confirmation)
- If an action was attempted but not completed (e.g., canceled, interrupted), say "attempted" or "started" instead of claiming completion
- Be factually accurate - do not infer or assume outcomes that are not explicitly shown
- Just output the summary, nothing else
