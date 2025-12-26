# Global instructions

## Output Chat Summary Rules
- **Summaries documentation** should use Markdown in your response unless asked to create documentation files.
- If creating **summaries documentation** files, save them only in `.claude/docs/`—do not place documentation elsewhere.

## Code of Conduct
- Follow <context-aware-hierarchical-delegation> in the whole session.
- **Clarity:** If intent is ambiguous, try 1: Use `recent-history` Skill to check last session context. 2. Ask clear clarifying questions (e.g., “Do you mean X or Y?”).
- **Good Output Format:** Use enhanced Markdown formatting for clarity.
- **Divergent thinking:** Extend your knowledge with web, kg tools, then use divergent thinking, use this for design, issue debugging.
- **Facts check on Plan/Outdated context:** It is 2025 year now, facts check based on existing code patterns, official documentation(from exa/web), or trusted sources (e.g., Stack Overflow). Do not assume facts without verification, your knowledge is 1 year behind.
- **Avoid trial-and-error:**: Use exa, kg, Explore to fetch relevant information before trial, then use divergent thinking.
- **Tests:**: Never write tests that purly verify third-party library behavior, write tests focus on our own code logic.

<context-aware-hierarchical-delegation>
- Prompt your direct and efficient instructions for subagent, ALWAYS give WHAT CAN DO, and WHAT CAN NOT DO to subagent to enforce efficient work. Bad example: "Please search in codebase for definition and usage of X"; Good example: "Please search in current codebase for definition and usage of X related to Y. You CAN use search tools, You CAN NOT edit or execute XX commands, you CAN only search in current codebase, if nothing find, you should finish immediately".
- Encapsulate noisy execution details inside the sub-agent's separate context, keeping the main timeline clean and focused on high-level decision making.
- **Rolling summarization:** Maintain and update a concise, lossless summary after each subagent completes. Keep total session state small and structured.
- Trigger subagents when you only want summaries or specific information.
- Trigger subagents if a fragmented workflow where simple tasks are taking too many steps.
- Trigger subagents if more than 3 consecutive direct tool calls, like read files, grep or searching for files, multiple web tool calls.
</context-aware-hierarchical-delegation>

## Planning and Implementation
- **Simplicity:** Write only essential code; use comments for potential features (do not implement them).
- **Reuse:** Prefer existing utilities/components via explicit interfaces—do not break abstraction boundaries.
- **Precedent:** Follow prior implementations for new features unless told otherwise.
- **Structured Plan:** For each step, specify target files and exact required changes.
- **Boundaries:** Keep business logic isolated from UI. Place demo/mock code at the top layer. Don't modify production code just for debugging.
- **Separation of concerns:** Bad: Use other layer's implement details in current layer that current layer should not know or care about. Good: current layer use it's own knowledge based implement details, dependant layers can depends on that to derive implement details.
- **Flexible consistency enforcement:**: Only enforce consistency if it not violate separate of concerns.
- **Abstraction:** Only use explicitly exposed abstractions from the immediate downstream layer—avoid private APIs, even for reuse.
- **Fail Fast:** Let bugs surface; do not mask errors with `try-catch` or optional chaining.
- **Comment Intent:** Use `FIXME`, `TODO`, and `NOTE` to flag issues, explain logic, document changes, and note trade-offs.
- **Comment as documentation:** Document any implement intent, decisions, critical findings in the code comment. Especially after a fix, document the reason behind the change.
- **Design for Testability:** Apply DfT principles from the start—use dependency injection, prefer pure functions, avoid global state, and design for controllability and observability. Create seams for testing; isolate components to enable independent verification.
- **Avoid introduce implement complexity:** No backward compatibility layers, feature flags, or toggles unless explicitly requested.
- **No external data based design:** Avoid designs relying on external data, for example, use external api data to determine program logic or control flow, it will broke when external data changes.
- **Avoid outdated dependency:** Use the latest stable version of dependencies unless there is a specific reason to use an older version. This is important to avoid big refactor later.
- **No Weak Test:**: Disallow tests that are meaningless to implemented code, or that do not effectively validate the intended functionality. Bad: Test to verify "id should not start with number", the test simply construct a string without number and assert with that, does not involve any implemented code.

When editing code: (1) state your assumptions, (2) create/run minimal tests if possible, (3) generate diffs ready for review, (4) follow repository style.

## Code Review
- **Manual Review:** Inspect edge cases, failures, and performance—do not rely only on automation.
- **Integration:** Ensure new code integrates with the application.
- **Reference:** Use `rg` or `ast-grep` to check correct API, constant, and variable use.

## Tool Knowledge: Knowledge Graph (`kg`)
- For batch queries, always use `limit` and request summary output.
- Use `group_id` for project organization (e.g., `<repo>_TODOS` or `<repo>_CHAT`).
- Keep saved knowledge concise, factual, and focused to reduce noise.
- **Critical:** Only verified facts may be recorded in `kg`—never unverified assertions.
- Facts must be confirmed by testing, running, or from trusted documentation (e.g., Stack Overflow or official docs).
- When updating an episode in `kg`, delete then recreate instead of updating in place.
- Always include the `episode_id` after creating a new episode.

## Additional Tools
- `sgrep XXX`: Use `bash ~/.claude/skills/fast-repo-context/scripts/sgrep.sh --json "query in English language"` for semantic code search.
- Other code tools: `ast-grep`, `fd`, and `rg`.

## Tool Use: Git Preferences
- Before Git write operations (commit/push), always check repository state using `git status`.
- **Must enforce rule**: Before run git commit commands, ask for user confirmation with a summary of changes.
- After confirmation and before committing or adding, recheck branch with `git status` to avoid committing to protected branches like `main` or `staging`.
- If a detached HEAD is detected, it uses `jj`—load the `git-jj` skill.
- For `jj`, refer to `~/.claude/skills/git-jj/references/jj_workflows.md`.
- Use the conventional commit format: `topic(scope): message`.
