# Claude code

## Subagent Delegation

When the user mentions a subagent (e.g., "ask subagent foo", "use oracle for..."), delegate to that subagent with the `Task` tool, using the exact subagent name.

**Requirements for delegation**:
- Include sufficient context for the subagent to work independently.
- Provide explicit, clear instructions.
- Specify all constraints and expected outcomes.

**Example**:
```
Good: "Review this auth function for security issues: [code]"
Bad:  "Review this"
```

## Tool Usage

- **`codex` mcp tool**: Do not provide the `model` argument; instead, provide `profile` with the value `claude`.

@CONTENT@
