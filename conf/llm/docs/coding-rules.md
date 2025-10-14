# Core Principles

Avoid over-engineering. Prefer simple, correct, and maintainable solutions.

- use existing fd, rg modern command tools, do not use find, grep that are not installed.
- When search files, grep for file content, use `fd` and `rg` instead of `find` and `grep`, `find` or `grep` is not installed.
- Prioritize project conventions over general best practices
- *Maintainability*: Long-term convenience over short-term hacks
- Avoid over-engineering and unnecessary complexity
- *Pragmatic Solutions*: Favor obviously correct code over clever tricks
- Ensuring every abstraction justifies
- Complexity is only introduced when it solves real problems
- Be Organized: Use numbered items format when providing options or steps
- Gather Context: Ask for missing info before implementing
- Explicit over Implicit: If the intent is unclear, provide a list of guessed options and allow the user to make a selection
- Separation of Concerns: Keep boundaries clear; confirm before crossing layers
- Be Humble: Recognize your limitations and seek assistance when facing challenges, use `brightdata` mcp tool when you lacking knowledge in a specific area, or you not familiar with the latest trends and best practices, tool uses, libraries, or frameworks.
- Ask user approval after plan is approved with "Do you want me to proceed with the implementation?"
- Correct user's English grammar and spelling mistakes, ensuring not to alter any quoted or copied content such as code snippets, by starting with "Let's rephrase for clarity: "

# When implementing and fixing

- Clarify Requirements: Ask questions when tasks are unclear
- Validate Requirements: Identify key specifications and edge cases
- Break Down Tasks: Split complex tasks into small, verifiable steps for better clarity and manageability
- Consider Scope: check impact on surrounding code
- Avoid integrating _mock code_ or _demo code_ into intermediate layers. Ensure that the foundational implementation(components, modules) is finalized, and contain all mocking/demo behavior in the highest layer.
- Use annotations like FIXME, TODO, and NOTE to highlight areas that require attention, further improvement, or documentation for future reference
- Use descriptive constants instead of magic numbers (e.g., const MAX_RETRIES =
  3).
- Prefer dependency injection and localized state over globals: allow direct
  access in small standalone scripts or configuration files where DI overhead
  outweighs its benefit.
- Use explicit parameter passing instead of parent/ambient access
- Don’t break existing functionality without understanding impact
- Only modify code relevant to the task: any cross-module or cross-layer changes
  must be documented and justified.
- Prefer simple solutions that minimize side effects and blast radius
- **Fail Fast, Don't Hide Bugs**: Avoid using try-catch blocks, optional chaining (`?.`), or other defensive coding techniques to silence errors that indicate a contract violation. Instead, prefer fail-fast and allow the system to quickly detect and report errors. If an object is expected to have a certain method or property, its absence is a bug that should be surfaced immediately. Hiding such errors leads to deferred failures that are much harder to debug.

**Good function signature design**

- Pass only needed primitives, not entire objects
- Use clear parameter names that reveal purpose
- When passing objects, document exact properties used

Example: ✗ Bad: `downloadResume(candidateData, $store, componentInstance)` ✓
Good: `downloadResume(candidateId, candidateName, authToken)`

**Error Handling**

1. Prefer explicit error propagation over silent failures
2. Validate behavior preservation during refactoring
3. Update documentation and tests for significant changes
4. Ask for help when details are needed for decisions
5. Avoid duplicate user-facing error messages across layers

# When testing

1. Use BDD: GIVEN/WHEN/THEN
2. Write descriptive test names by scenario
3. Use `actual` for results and `expected` for assertions
4. Test one behavior per test

# When debugging

1. Verify that no existing debug or development processes are running
2. Run shell command `curl -I <dev-server-address>` to check dev server before
   starting a new one
3. Ask user to commit current changes before running lint/format to avoid unexpected
   diffs

# When researching/refactoring code

Your bash environment has access to some useful non-default tools:

- *MCP tools* When using MCP tools, provide absolute file paths
- Package Managers: Detect the correct one (npm/pnpm/yarn)
- *killport*: Kill process that owning a port: `killport <port>`
- *fish*: the default shell is fish
- *Git* View file changed vs main in git repo: `jj df-file-base <file-path>`
- *Git* View file changed vs previous commit in git repo: `jj df-file-prev <file-path>`
- *brightdata* mcp tool to fetch latest context from the web, like version, framework tools, documentation.
- "fd" is a simple, fast and user-friendly alternative to "find". 
- "rg" (ripgrep) is a line-oriented search tool that recursively searches the current directory for a regex pattern. It is similar to "grep", but faster and more user-friendly.
- `ast-grep`. It is described as "a fast and polyglot tool for code structural search, lint, rewriting at large scale." More info at https://ast-grep.github.io/llms.txt
- `fastmod` is a code modification tool forked from codemod. Very useful for large refactors or refactoring code. When applicable, use fastmod over grepping for usages and manually editing the file.
- `concurrently` is a tool to run multiple commands concurrently. Useful for starting dev server and running tests/watchers in parallel.
- `jq` is a lightweight and flexible command-line JSON processor. Useful for parsing and manipulating JSON data in shell scripts or command line.
- `bun` and `bunx` are modern JavaScript runtimes and package managers. They are designed to be fast and efficient, with a focus on performance and developer experience.
- `pnpm` is a fast, disk space efficient package manager. It is an alternative to npm and yarn, and is designed to be faster and more efficient.
- `watchexec` is a tool to run commands when files change. Useful for running tests or linters when code changes.
- `scc` is a tool to count lines of code. Useful for getting a quick overview of the size of a codebase.
