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
- **find**: Search files with `Bash(fd)`. It is forbidden to use `Bash(find)`.
- **grep**: Grep file content with `ast-grep`. Fallback to `Search(pattern:*,path:*)` or `Bash(rg)` if `ast-grep` is not applicable. `Bash(grep)` is deprecated and has been removed from this machine.
- **grep github code**: Use `<mcp-grep-code>mcp__grep-code__searchGithub</mcp-grep-code>`.

@CONTENT@
