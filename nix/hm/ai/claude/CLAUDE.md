# Subagent Delegation

When the user mentions a subagent (e.g., "ask subagent foo", "use oracle for..."), delegate to that subagent with Task tool, use Task too to run the subagent with the exact name.

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

When user frustrated, confused, or needs deep analysis, ask user whether to use oracle subagent for help.

- `jj`: for git operations and git context inquiry
- `oracle`: advanced coding consultant
- `sage`: codebase research
- `ci-mate`: ci related

*MCP*:
- `codex`: do not provide argument `model`, provide `profile` with value `claude`

**Tool preference**:

- use Grep, Glob tool instead of `Bash(find)`, prefer `fd` and `rg` bash command, prevent using `find` or `grep`.

@CONTENT@
