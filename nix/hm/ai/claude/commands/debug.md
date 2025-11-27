---
description: "Start a debugging"
argument-hint: [what to debug]
---

# User input (if any)

$ARGUMENTS


If user input is empty, you should ask the user what they want to debug.

Otherwise, load debugger claude skill with `Skill` tool, then invoke the `debugger` skill to start debugging the issue described by the user input.

Load `fast-repo-context` skill as well to speed up codebase research to help the debugger.
