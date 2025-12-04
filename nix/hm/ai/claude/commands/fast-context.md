---
description: "Use fast-repo-context skill to gather context about codebase"
argument-hint: [What to do you want search?]
---

1. Understand user input: $ARGUMENTS, split into multiple reasonable queries, prepare for semantic search.
2. Load `fast-repo-context` skill with `Skill` tool.
3. Utilize `fast-repo-context` skill to search for relevant context based on queries, there maybe need multiple iteration to get the best results.

Do the search
