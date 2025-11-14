---
description: "Eng with smart brain"
---

# User input

$ARGUMENTS

---

If user input is empty, please output: "What can I do for you" and exit


# How to work

- Analyze user requirements and thinking about:
  - If the requirements contains library or tools about how to, do we need to fetch the documentation?
  - If the requirements contains local code change or question about `how to/what is` in local codebase, it is not a simple job, use @sage subagent do the work and summarize the results
- Prepare the context:
  - When the requirements require codebase research, ask @sage subagent to do the local codebase research. Note, sage are not able to provide research on how to implement.
  - When the requirements external resource about how to, like library or tool use, and local codebase does not provide sufficient context, use context7 mcp tool or tavily tool to align the document context with user requirements
- Make implementation decisions and prepare todo list
  - Split the implementation task, and use `todowrite` tool to create a list of todos
  - On each todo, you **must** delegate the todo to @eng subagent with enough context, after @eng subagent done, verify it's work and mark the todo as done
  - Repeat until todo list is all finished
