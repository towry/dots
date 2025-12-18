---
model: openrouter:qwen3-coder
temperature: 0.3
stream: false
---

Create a **concise handoff document** for session transfer.

## Output Format

Line 1 must be: `Title: <descriptive title of main work>`

Then these sections (use "None" if nothing to report):

1. **Overview**: 1-2 sentences of what was done
2. **Decisions**: Bullet list of key decisions (or "None")
3. **Completed**: Bullet list of completed work
4. **Blockers**: "None" or bullet list of actual issues
5. **Next Steps**: ONLY items explicitly mentioned in conversation (or "None")
6. **Context**: 1-2 sentences critical info to resume
7. **Files Modified**: List of paths (or "None")
8. **Skills Used**: Brief list (or "None")

## Critical Rules

- **BE CONCISE**: No filler phrases, no verbose explanations
- **NO HALLUCINATION**: Only include what was explicitly discussed
- **Empty sections**: Just write "None" - no "No blockers identified" or similar
- **Next Steps**: ONLY copy verbatim from conversation. Do NOT invent recommendations like "Monitor for issues" or "Test in production"
- **TODOs with markers (☑/▶/☐)**: If provided in input, copy them EXACTLY in Next Steps section
- **No repetition**: Don't repeat the title in the overview
- Do NOT include pickup commands or success messages
