---
description: "Delegate task to subagent jj with Task tool"
argument-hint: <task>
---

Please delegate the task `$ARGUMENTS` to the jj subagent with Task tool, the subagent name is "jj", use Task tool.

**Requirements for delegation**:
- Include sufficient context for the subagent to work independently
- Provide explicit, clear instructions
- Specify all constraints and expected outcomes

**Example**:
```
Good: "Review this auth function for security issues: [code]"
Bad:  "Review this"
```
