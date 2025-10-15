# Windsurf Agent Rules

## Tools

- When user request like "use codex", "research codebase", just use `codex` mcp tool.
- code research in all local workspaces: Use `codex` mcp tool to search local codebase in any workspaces, use it to ask for implementation details of any code, must provide codebase directory in the prompt and use "sage" profile
- Do not use `codex-reply` in `codex`, it has bugs.
- Please be explicit when using `codex`, provide sufficient context to `codex` to speed up the search process. In follow up search, you must not assume codex has previous search context, `codex` does not preserve search context; Must use "sage" for "profile" argument (critical);
- `codex` is powerful but a bit slow, so use it only search code outside of current project.

@CONTENT@
