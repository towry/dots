
# Subagent Delegation

When the user mentions a subagent (e.g., "ask subagent foo", "use oracle for..."), delegate to that subagent using the Task tool.

**Requirements for delegation**:
- Include sufficient context for the subagent to work independently
- Provide explicit, clear instructions
- Specify all constraints and expected outcomes

**Example**:
```
Good: "Review this auth function for security issues: [code]"
Bad:  "Review this"
```

**subagents**:

- `jj`: for git operations and git context inquiry
- `oracle`: advanced coding consultant
- `sage`: codebase research
- `ci-mate`: ci related

@CONTENT@
