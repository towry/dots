# Critical rules

Avoid over-engineering. Prefer simple, correct, and maintainable solutions.

1. Be Organized: Use numbered lists for options, steps, or requirements
2. Be Transparent: Use FIXME, TODO, NOTE when relevant
3. Be Clear: Document assumptions and requirements briefly in comments
4. Gather Context: Ask for missing info before implementing
5. Explicit over Implicit: If intent is unclear, list concise options and let
   the user choose
6. Separation of Concerns: Keep boundaries clear; confirm before crossing layers
7. Be Humble: Acknowledge limitations and ask for help when stuck
8. If you encounter a port conflict, it usually means the service is already
   running, or you can use the `killport <port>` shell command to terminate the
   process.

# Development Process

1. Clarify Requirements: Ask questions when tasks are unclear
2. Validate: Identify key requirements and edge cases
3. Break Down: Split into small, verifiable steps
4. Consider Scope: Check impact on surrounding code

# Critical: Code Quality

- Add FIXME, TODO, NOTE for important notices
- Write helpful comments for “why”, prefer self-documenting code for “what”
- Prioritize correctness and clarity over micro-optimizations
- Follow DRY pragmatically: apply SOLID principles when they improve readability
  and maintainability; avoid unnecessary abstractions that do not solve a clear
  problem.
- Use descriptive constants instead of magic numbers (e.g., const MAX_RETRIES =
  3).
- Preserve existing structure and style unless they contradict project standards
  or cause readability/maintainability issues.
- Prefer dependency injection and localized state over globals: allow direct
  access in small standalone scripts or configuration files where DI overhead
  outweighs its benefit.
- Use explicit parameter passing instead of parent/ambient access
- Don’t break existing functionality without understanding impact
- Only use APIs/variables you are certain exist; otherwise confirm or guard
- Only modify code relevant to the task: any cross-module or cross-layer changes
  must be documented and justified.
- Prefer simple solutions that minimize side effects and blast radius

**Good function signature design**

- Pass only needed primitives, not entire objects
- Use clear parameter names that reveal purpose
- When passing objects, document exact properties used

Example: ✗ Bad: `downloadResume(candidateData, $store, componentInstance)` ✓
Good: `downloadResume(candidateId, candidateName, authToken)`

# Testing

1. Use BDD: GIVEN/WHEN/THEN
2. Write descriptive test names by scenario
3. Use `actual` for results and `expected` for assertions
4. Test one behavior per test

# Debug

1. Ensure no existing debug/dev process is running
2. Run shell command `curl -I <dev-server-address>` to check dev server before
   starting a new one
3. Ask to commit current changes before running lint/format to avoid unexpected
   diffs
4. Avoid inserting mock or debug code directly into implementation modules;
   instead, use top-level scaffolding or dedicated debug modules to manage test
   data and keep core logic clear.

# Shell commands

1. Search Tools: Use `fd` for files, `rg` for content
2. File Operations: Provide absolute file paths to MCP tools
3. Package Managers: Detect the correct one (npm/pnpm/yarn)
4. Kill by port: `killport <port>`
5. Running shell commands: Detect current shell and use correct syntax
6. File changed vs main: `jj df-file-base <file-path>`
7. File changed vs previous commit: `jj df-file-prev <file-path>`

# Error Handling

1. Prefer explicit error propagation over silent failures
2. Validate behavior preservation during refactoring
3. Update documentation and tests for significant changes
4. Ask for help when details are needed for decisions
5. Avoid duplicate user-facing error messages across layers
