# Agent Rules

## Critical

- Avoid over-engineering; write only the code necessary to meet the user's request. Do not add extra features or functionality unless explicitly asked. It's fine to document such nice-to-haves in comments or documentation for future reference.
- Easy reference and recommendation: Number any options, steps, or requirements so users can cite them by number.
- Be transparent about code intention: flag anything that needs attention with FIXME, TODO, or NOTE.
- **Be clear in code**: document any non-obvious logic and explain what complex functions are for.
- **Explicit over implicit in conversation**: when user intent is unclear, list the likely options and let the user pick, interpret user message with scope, like "Are you asking for X or Y?", and "Are you talking about ci in 'Continuous Integration' or just code variable name in current codebase?".
- **Keep boundaries clear**: UI components should not contain business logic, demo code, debug logic, temporary code, or mock code.
- **Stay humble**: push yourself to solve the problem first, but if you hit a hard limit, say so and ask for help—never fake an answer.
- **One-check rule**: present your plan up front; if the user says nothing, proceed—only ask again if the scope changes.
- **Polish, don’t paraphrase**: if the user’s English is off, say “Let’s rephrase for clarity:” and fix only the grammar or spelling—leave any quoted code or copied text untouched.

## Plan

- Follow the house style first: check one of `.github/instructions/*.md` and `.windsurf/rules/`
- Model your plan on what’s already there: start by searching for the most similar existing feature Y, then adapt it for the new feature X—unless the user tells you to start from scratch.
- Every implementation step must state the target file and the exact changes to be made.
- Add a verification step to every task, pick one: unit test, Playwright interactive check, or manual verification.
- Before writing anything new, scour the codebase for reusable building blocks and list them in the plan. For instance, when a new API is introduced, first look for an existing data-transformation utility (e.g., snake-case ↔ camel-case mappers, date-format normalizers, pagination wrappers, etc.) instead of creating another one.
- Add review checkpoints after each major step, especially when working on complex features or refactoring existing code.

## Review

- Read project `AGENTS.md` and `~/.config/AGENTS.md` (or your own instructions) and obey the `## Critical` rules.
- Confirm every change is wired in: new handlers must be bound, new routes registered, etc. no orphaned code.
- Conduct a deep, human review, not just static-code checks: walk through every edge case, anticipate failure modes, and weigh the performance cost of each path.
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
- Before adding any fraction utilities, carefully search the codebase for existing ones—reuse, don’t duplicate.

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

## Debugging and issue analysis

- Verify that no existing debug or development processes are running.
- Run shell command `curl -I $dev-server-address$` to check dev server before starting a new one.
- Ask user to commit current changes before running lint/format to avoid unexpected diffs.
- Explain the issue or bug analysis results to user first, then ask for confirmation to make any code changes.

## Git 

- In git commit message, add scope if possible, for example: `feat(auth): msg here`

## Tools available in current environment

- **grep**(ast-grep): Whenever a search requires syntax-aware or structural matching, use `ast-grep run --lang ? --pattern ? [PATHS]...` (set `--lang` appropriately, default to lang in `lang` tags), fallback to text-only tool `rg`.
- **[find, grep](fd,rg)**: To search for files, use `fd`. The `find` shell command is deprecated and removed.
- **Package Managers(pnpm, bun)**: Use pnpm when possible.
- **port occupied(killport)**: To kill a process that is using a port, use `killport $port$`.
- **shell**: The current shell is `fish`.
- **search web and scrape html**: Use the `brightdata` mcp tool to fetch the latest context from the web, like version, framework tools, and documentation.
- `github` mcp tool: search public GitHub repositories for code examples.
- `gh`: github cli
- `memory` mcp tool: to store and retrieve short-term memory across the conversations, use memory tool when you have vague context in current chat due to context compression.

#### playwright mcp tool

- Always try to navigate again when you encounter a timeout error
