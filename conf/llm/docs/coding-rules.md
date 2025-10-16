# Agent Rules

## Critical

- Avoid over-engineering, only write coding that explicitly addresses the user's request.
- **Easy to reference your options**: Use numbered lists for options, steps, or requirements, so user can use number to reference the choice.
- **Be Transparent**: Use FIXME, TODO, NOTE when relevant.
- **Be Clear**: Document non-obvious logic and the purpose of complex functions.
- **Explicit over Implicit**: If the intent is unclear, provide a list of guessed options and allow the user to make a selection.
- **Keep boundaries clear**: UI components should not contain business logic, demo code, debug logic, temporary code, or mock code.
- **Be Humble**: Recognize your limitations and seek assistance when facing challenges.
- Seek user approval for your implementation plan before proceeding.
- Correct user's English grammar and spelling mistakes, ensuring not to alter any quoted or copied content such as code snippets, by starting with "Let's rephrase for clarity: ".
- **Ability**: You know everything about code, with `codex` mcp tool, you can search any local codebase in any workspaces; With web search tool, brightdata, you can search anything on the web, and scrape html content; with grep-code mcp tool (if available), you can search code patterns from GitHub public codebase.
- **Allowed search dirs**: `$HOME/workspace/`, `/tmp`; do not search on `$HOME` root directory;

## Plan

- Prioritize existing codebase convention over edge-cutting best practices, search for `.github/instructions/*.md`, `.windsurf/rules/` for project convention rules, use `codex` mcp tool for codebase research.
- Plan based on existing similar functionality, unless user explicitly requests otherwise, for example, When implement feature X, with slightly difference between feature Y, then plan based on feature Y, search if there are similar feature Y at the start of plan; It is ok to explicitly ask for such information about similar feature.
- Each implementation step should contain file location and changes.
- Add verification steps to the plan, options: unit testing; playwright interactive verify; manually verify.

## Review

- Read project AGENTS.md and `~/.config/AGENTS.md`, or your instructions, ensure changes follow the coding rules, especially the `## Critical` section.
- Check if code changes is unused or disconnected from the system, for example, added an event handler function/method, but did not bind to the ui component, cause event flow disruption.
- **correct code reference**: For api, constant, variable usage, use `ast-grep` or `rg` to fast search for code patterns, ensure no assumption code added, for example, added `this.userType = 123`, but `userType` with value `123` is none-sense in the project.

## Implementation

- **Prioritize functionality**: Ensure the core features work correctly before optimizing or adding enhancements, like excessive ui animations.
- **Clarify Requirements**: Ask questions when tasks are unclear.
- **Validate Requirements**: Identify key specifications and edge cases.
- **Break Down Tasks**: Split complex tasks into small, verifiable steps for better clarity and manageability.
- Avoid integrating _mock code_ or _demo code_ into intermediate layers. Ensure that the foundational implementation(components, modules) is finalized, and contain all mocking/demo behavior in the highest layer.
- Use annotations like FIXME, TODO, and NOTE to highlight areas that require attention, further improvement, or documentation for future reference.
- Use descriptive constants instead of magic numbers (e.g., `const MAX_RETRIES = 3`).
- Prefer dependency injection and localized state over globals: allow direct access in small standalone scripts or configuration files where DI overhead outweighs its benefit.
- **function/method**: Use explicit parameter passing instead of parent/ambient access.
- Only modify code relevant to the task: any cross-module or cross-layer changes must be documented and justified.
- **Fail Fast, Don't Hide Bugs**: Avoid using try-catch blocks, optional chaining (`?.`), or other defensive coding techniques to silence errors that indicate a contract violation. Instead, prefer fail-fast and allow the system to quickly detect and report errors. If an object is expected to have a certain method or property, its absence is a bug that should be surfaced immediately. Hiding such errors leads to deferred failures that are much harder to debug.

### Function Signature Design

- Pass only needed primitives, not entire objects.
- Use clear parameter names that reveal purpose.
- When passing objects, document exact properties used.

**Example**:
- ✗ **Bad**: `downloadResume(candidateData, $store, componentInstance)`
- ✓ **Good**: `downloadResume(candidateId, candidateName, authToken)`

### Error Handling

- Prefer explicit error propagation over silent failures.
- Validate behavior preservation during refactoring.
- Update documentation and tests for significant changes.
- Ask for help when details are needed for decisions.
- Avoid duplicate user-facing error messages across layers.

## Testing

- **Use BDD**: GIVEN/WHEN/THEN
- Write descriptive test names by scenario.
- Use `actual` for results and `expected` for assertions.
- Test one behavior per test.

## Debugging

- Verify that no existing debug or development processes are running.
- Run shell command `curl -I $dev-server-address$` to check dev server before starting a new one.
- Ask user to commit current changes before running lint/format to avoid unexpected diffs.

## Tool Usage

- **grep**: Whenever a search requires syntax-aware or structural matching, use `ast-grep run --lang ? --pattern ? [PATHS]...` (set `--lang` appropriately, default to lang in `lang` tags), fallback to text-only tool `rg`.
- **find**: To search for files, use `fd`. The `find` shell command is deprecated and removed.
- **Package Managers**: Use pnpm when possible.
- **port occupied**: To kill a process that is using a port, use `killport $port$`.
- **shell**: The current shell is `fish`.
- **git**: To view file changes against the main branch, use `jj df-file-base ?file-path?`.
- **git**: To view file changes against the previous commit, use `jj df-file-prev ?file-path?`.
- **search web and scrape html**: Use the `brightdata` mcp tool to fetch the latest context from the web, like version, framework tools, and documentation.
- *codex*: Use the `codex` mcp tool with specific profile for different tasks, "sage" profile for codebase research, "claude" for high reasoning tasks; 'claude_fast' for low reasoning task; Do not use model argument; Limit the cwd argument up to the allowed search dirs in our critical rule; do not use `cwd` argument, include the cwd in the `prompt` argument.

### codex codebase research usage example

```json
{
  "prompt": "Search xxx in cwd: yyy",
  "profile": "sage"
}
```

### GitHub Code Search, do not use this when request for local codebase search

*Pattern search code from GitHub with the tool in `mcp-grep-code` tags, default to `grep-code` mcp tool, example:*

```json
{
 "query": "(?s)server\\.tool.*catch",
 "language": [
  "TypeScript",
  "JavaScript"
 ],
 "useRegexp": true
}
```

## Troubleshooting for tool issues

- grep, search failed with our builtin tools, try use `codex` mcp tool with "sage" profile.
