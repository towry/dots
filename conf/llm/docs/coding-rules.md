# Agent Rules

## Core Principles
- **Clarity First**: Present all outputs in clean, scannable Markdown. When user intent is unclear, offer explicit options (e.g., "Do you mean X or Y?").
- **Simplicity**: Write the minimum code required. Document potential future features as comments, but do not implement them.
- **Humility**: If you hit a technical limit, state it clearly and ask for help. Never invent an answer.
- **Efficiency**: Present your plan once. Proceed unless the user objects or changes the scope.
- **Respect User's Voice**: If the user's writing is unclear, rephrase it for clarity ("Rephrasing for clarity: ...") but never alter quoted code or technical terms.
- **Better output format**: Use markdown format with colorful format to improve response readability.

## Planning & Implementation
- **Reuse, Don't Rebuild**: Before writing new code, search the codebase for existing utilities, components, or patterns.
- **Follow Precedent**: Model new features on existing ones unless instructed otherwise.
- **Structured Plan**: Each implementation step must specify the target file and the exact changes.
- **Clear Boundaries**: Keep business logic out of UI components. Isolate mock or demo code to the highest application layer.
- **Fail Fast**: Do not hide bugs with `try-catch` or optional chaining (`?.`). Let errors surface immediately to prevent harder-to-debug deferred failures.
- **Document Intent**: Use `FIXME`, `TODO`, and `NOTE` to flag areas needing attention. Document non-obvious logic.

## Code Review
- **Deep Review**: Go beyond static checks. Manually walk through edge cases, failure modes, and performance impacts.
- **Verify Integration**: Ensure all new code (handlers, routes, etc.) is correctly wired into the application.
- **Reference Check**: Use tools like `rg` to confirm all referenced APIs, constants, and variables exist and are used correctly.

#### Knowledge & Tools
- **Knowledge Graph (`kg`)**:
    - Use `kg` to store important information like summaries, facts, and user preferences for long-term memory.
    - Use `group_id` to organize information by project (e.g., `<repo_name>_TODOS`, `<repo_name>_CHAT`).
    - After completing a task, save key takeaways to `group_id: "lesson_learned"`.
- **User Preferences**:
    - VCS: `jj`
    - Search: `fd` and `rg`
