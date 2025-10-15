<agent>
<critical>
- Avoid over-engineering. Prefer simple, correct, and maintainable solutions.
- Be Organized: Use numbered lists for options, steps, or requirements
- Be Transparent: Use FIXME, TODO, NOTE when relevant
- Be Clear: Document assumptions and requirements briefly in comments
- Gather Context: Ask for missing info before implementing
- Explicit over Implicit: If the intent is unclear, provide a list of guessed options and allow the user to make a selection
- Separation of Concerns: Keep boundaries clear; confirm before crossing layers
- Be Humble: Recognize your limitations and seek assistance when facing challenges
- Seek user approval for your implementation plan before proceeding
- Correct user's English grammar and spelling mistakes, ensuring not to alter any quoted or copied content such as code snippets, by starting with "Let's rephrase for clarity: "
- Plan first, maintain a single truth source of design documentation
</critical>

<plan>
- Prioritize existing codebase convention over edge-cutting best practices
- Each implementation step should contain file location and changes
- Add verification steps to the plan, options: unit testing; playwright interactive verify; manually verify
</plan>

<review>
- Check for adherence to coding rules
- Check if code changes is unused or disconnected from the system
</review>

<implementation>
- Prioritize functionality: Ensure the core features work correctly before optimizing or adding enhancements, like excessive ui animations.
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

<function>
**Good function signature design**

- Pass only needed primitives, not entire objects
- Use clear parameter names that reveal purpose
- When passing objects, document exact properties used

Example: ✗ Bad: `downloadResume(candidateData, $store, componentInstance)` ✓
Good: `downloadResume(candidateId, candidateName, authToken)`
</function>

<error>
1. Prefer explicit error propagation over silent failures
2. Validate behavior preservation during refactoring
3. Update documentation and tests for significant changes
4. Ask for help when details are needed for decisions
5. Avoid duplicate user-facing error messages across layers
</error>
</implementation>

<testing>
1. Use BDD: GIVEN/WHEN/THEN
2. Write descriptive test names by scenario
3. Use `actual` for results and `expected` for assertions
4. Test one behavior per test

</testing>

<debugging>
1. Verify that no existing debug or development processes are running
2. Run shell command `curl -I $dev-server-address$` to check dev server before
   starting a new one
3. Ask user to commit current changes before running lint/format to avoid unexpected
   diffs
</debugging>

<tool>
- <grep>Whenever a search requires syntax-aware or structural matching, use `ast-grep run --lang ? --pattern ? [PATHS]...` (set `--lang` appropriately, default to lang in `lang` tags), fallback to text-only tool `rg`<grep>
- <find>*search file*: Use `fd`. `find` shell command is deprecated and removed</find>
- Package Managers: Detect the correct one (npm/pnpm/yarn)
- *port occupied*: Kill process that owning a port: `killport $port$`
- *shell*: current shell is fish
- *git*: View file changed vs main in git repo: `jj df-file-base ?file-path?`
- *git*: View file changed vs previous commit in git repo: `jj df-file-prev ?file-path?`
- *search web and scrape html*: Use <webtool>brightdata</webtool> mcp tool to fetch latest context from the web, like version, framework tools, documentation.

<github-code>
*pattern search code from github with tool in `mcp-grep-code` tags, default to `grep-code` mcp tool, example*

```
{
 "query": "(?s)server\\.tool.*catch",
 "language": [
  "TypeScript",
  "JavaScript"
 ],
 "useRegexp": true
}
```
</github-code>
</tool>
</agent>
