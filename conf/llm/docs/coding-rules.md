# Agent Rules

## Core Principles
- **Clarity First**: Present all outputs in clean, scannable Markdown. When user intent is unclear, offer explicit options (e.g., "Do you mean X or Y?").
- **Simplicity**: Write the minimum code required. Document potential future features as comments, but do not implement them.
- **Humility**: If you hit a technical limit, state it clearly and ask for help. Never invent an answer. 
- **Efficiency**: Present your plan once. Proceed unless the user objects or changes the scope.
- **Tolerate user's English grammar issue**: Ignore user's minor grammar mistakes and focus on the intent.
- **Better output format**: Use markdown format with colorful format to improve response readability.

## Planning & Implementation
- **Reuse, Don't Rebuild**: Before writing new code, search the codebase for existing utilities, components, or patterns.
- **Follow Precedent**: Model new features on existing ones unless instructed otherwise.
- **Structured Plan**: Each implementation step must specify the target file and the exact changes.
- **Clear Boundaries**: Keep business logic out of UI components. Isolate mock or demo code to the highest application layer. Never change working implementation code just for debug logs.
- **Fail Fast**: Do not hide bugs with `try-catch` or optional chaining (`?.`). Let errors surface immediately to prevent harder-to-debug deferred failures.
- **Document Intent in code comment**: Use `FIXME`, `TODO`, and `NOTE` to flag areas needing attention; Document non-obvious logic, change intention, code changes, and any trade-offs made.

## Code Review
- **Deep Review**: Go beyond static checks. Manually walk through edge cases, failure modes, and performance impacts.
- **Verify Integration**: Ensure all new code (handlers, routes, etc.) is correctly wired into the application.
- **Reference Check**: Use tools like `rg` to confirm all referenced APIs, constants, and variables exist and are used correctly.

#### Knowledge & Tools
- **Knowledge Graph (`kg`)**:
    - Use `kg` to store important information like summaries, facts, and user preferences for long-term memory.
    - When batch query `kg`, always use `limit` and `summary` output to avoid too much irrelevant information.
    - Use `group_id` to organize information by project (e.g., `<repo_name>_TODOS`, `<repo_name>_CHAT`).
    - After completing a task, save key takeaways to `group_id: "lesson_learned"`.
    - Keep content concise and focused on facts, key insights, only contain neccessary information, to reduce noise when retrieving later.
    - **critical**: Do not save assertions from debugging task that are not verified as facts.
    - When user want to update an epsode/memory in `kg`, first delete the old one, then create a new one, kg does not support `update` action.
    - Always include `episode_id` in output after new episode created with kg.
- **User Preferences**:
    - VCS: `jj`
    - Search: `fd` and `rg`
    - `ls` alternative: `exa`
    - When user says `sgrep XXX`, run `bash ~/.claude/skills/fast-repo-context/scripts/sgrep.sh --json "XXX"` to search code semantically and fast.
- **git**:
    - Only run git commit commands after user confirm the changes is ok.
    - Before git commit and git add, check current branch, prevent accidental commit to main/staging branch.
