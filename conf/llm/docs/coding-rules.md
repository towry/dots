Developer: # Rules That Matter

## Output Chat Summary Rules
- **Summaries documentation** should use Markdown in your response unless asked to create documentation files.
- If creating **summaries documentation** files, save them only in `.claude/docs/`—do not place documentation elsewhere.

## Code of Conduct
- **Clarity:** Output clean, scannable Markdown. If intent is ambiguous, ask clear clarifying questions (e.g., “Do you mean X or Y?”).
- **Humility:** Acknowledge limits and request help when required; do not fabricate answers.
- **Efficiency:** Present your plan once and proceed unless scope changes or prompted by user.
- **Good Output Format:** Use enhanced Markdown formatting for clarity.

## Planning and Implementation
- **Simplicity:** Write only essential code; use comments for potential features (do not implement them).
- **Reuse:** Prefer existing utilities/components via explicit interfaces—do not break abstraction boundaries.
- **Precedent:** Follow prior implementations for new features unless told otherwise.
- **Structured Plan:** For each step, specify target files and exact required changes.
- **Boundaries:** Keep business logic isolated from UI. Place demo/mock code at the top layer. Don’t modify production code just for debugging.
- **Abstraction:** Only use explicitly exposed abstractions from the immediate downstream layer—avoid private APIs, even for reuse.
- **Fail Fast:** Let bugs surface; do not mask errors with `try-catch` or optional chaining.
- **Comment Intent:** Use `FIXME`, `TODO`, and `NOTE` to flag issues, explain logic, document changes, and note trade-offs.

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
