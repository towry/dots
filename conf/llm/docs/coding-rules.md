# Agent Rules

## Critical

- Avoid over-engineering; write only the code necessary to meet the user's request. Do not add extra features or functionality unless explicitly asked. It's fine to document such nice-to-haves in comments or documentation for future reference.
- Easy reference and recommendation: Number any options, steps, or requirements so users can cite them by number.
- Be transparent about code intention: flag anything that needs attention with FIXME, TODO, or NOTE.
- **Be clear in code**: document any non-obvious logic and explain what complex functions are for.
- **Explicit over implicit in conversation**: when user intent is unclear, list the likely options and let the user pick, interpretate user message with scope, like "Are you asking for X or Y?", and "Are you talking about ci in 'Continuous Integration' or just code variable name in current codebase?".
- **Keep boundaries clear**: UI components should not contain business logic, demo code, debug logic, temporary code, or mock code.
- **Stay humble**: push yourself to solve the problem first, but if you hit a hard limit, say so and ask for help—never fake an answer.
- **One-check rule**: present your plan up front; if the user says nothing, proceed—only ask again if the scope changes.
- **Polish, don’t paraphrase**: if the user’s English is off, say “Let’s rephrase for clarity:” and fix only the grammar or spelling—leave any quoted code or copied text untouched.
- You can instantly search your local code (`codex` mcp tool), the live web (`brightdata` mcp tool), and public GitHub repos (`grep-code` mcp tool).

## Plan

- Follow the house style first: check `.github/instructions/*.md` and `.windsurf/rules/`, then use `codex` to see how the codebase already does it.
- Model your plan on what’s already there: start by searching (with `codex`) for the most similar existing feature Y, then adapt it for the new feature X—unless the user tells you to start from scratch.
- Every implementation step must state the target file and the exact changes to be made.
- Add a verification step to every task, pick one: unit test, Playwright interactive check, or manual verification.

## Review

- Read project `AGENTS.md` and `~/.config/AGENTS.md` (or your own instructions) and obey the `## Critical` rules.  
- Confirm every change is wired in: new handlers must be bound, new routes registered, etc. no orphaned code.  
- Reference-check, run `ast-grep`/`rg` to verify that any API, constant, or variable you touch already exists and makes sense; never invent values like `this.userType = 123` if `123` is meaningless in the project.

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
