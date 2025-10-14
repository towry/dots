<agent>

<subagent>
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
</subagent>


<tool>
- `codex` mcp tool: do not provide argument `model`, provide `profile` with value `claude`
- <find>Search files with `Bash(fd)`, It is forbidden to use `Bash(find)`</find>
- <grep>Grep file content with `ast-grep`, fallback to `Search(pattern:*,path:*)` tool or `Bash(rg)` tool if `ast-grep` is not applicable, `Bash(grep)` is deprecated and removed from this machine, fallback to tool in  <grep> tags.</grep>
- grep github code: <mcp-grep-code>mcp__grep-code__searchGithub</mcp-grep-code>
</tool>

</agent>

@CONTENT@
