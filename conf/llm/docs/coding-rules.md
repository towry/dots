# Critical rules

**Avoid over-engineering**

1. **Be Organized**: Use numbered lists when presenting options, steps, or
   requirements for easy referencing
2. **Be Proactive Transparent**: List follow-up actions and comment markers
   (FIXME, TODO, NOTE) when relevant
3. **Be Clear**: Document requirements in comments to ensure mutual
   understanding
4. **Gather Context**: Always seek sufficient information and clarification
   before implementing solutions
5. **Explicit over Implicit**: For user requirements, if not confident in user
   intent, list concise options let user choose which one is the truly intent.
6. **Separation of Concern**: Maintain clear boundaries between different
   components and responsibilities. If user prompt violates separation of
   concern, agent must ask for confirmation before proceeding.
7. **Be Humble**: Acknowledge limitations and assist users with problems that
   you don't fully understand or are stuck on.
8. **Collaborative Debugging**: Provide clear debug steps, ask users for
   results, and iteratively solve problems together.
9. **Process Conflict Prevention**: Before running commands that start
   long-running processes, verify no conflicting processes are already running.
   For example, starting multiple instances of `npm run dev` can break existing
   tasks and cause unexpected behavior.

# Development Process

1. **Clarify Requirements**: Ask for additional information if tasks are unclear
2. **Validate Requirements**: Identify key requirements and edge cases
3. **Break Down Tasks**: Divide complex tasks into small, manageable steps
4. **Use Comment Markers**: Add FIXME, TODO, NOTE comments for unclear
   implementations
5. **Consider Scope**: Think about how changes may affect surrounding code

# Critical: Code Quality

- Add FIXME, TODO, NOTE comments for important notice
- Write helpful comments
- Avoid over-engineering, top-priority rule!
- Make function contracts clear
- Prioritize correctness over efficiency
- Follow DRY principles but don't religiously follow SOLID
- Use descriptive constants instead of magic numbers
- Prefer self-documenting code over comments (except for "why" explanations)
- Keep files under 2000 lines
- Avoid code that increases maintenance burden
- Handle async operations in centralized, high-level components for better
  control and correctness (avoid scattered async logic that creates
  unpredictable behavior)
- Improves readability
- Reduces verbosity
- Minimize property lookup overhead for better performance
- Write code that's easy to refactor
- Never include sensitive user or machine information in code or comments
- Prefer dependency injection and localized state over global dependencies
- Use explicit parameter passing instead of parent component access
- Never break existing functionality without understanding the impact
- Only use variables/methods you're certain exist, otherwise ask the user
- Don't remove code you don't understand
- Preserve existing code structure and style unless it's flawed
- Break large tasks into smaller, verifiable steps
- Check for external dependencies before editing files
- Only modify code relevant to the task
- Avoid major pattern changes unless necessary
- Avoid over-engineering
- Prefer simple solutions that minimize side effects and impact on the codebase

**Good Function Signature design**:

- Pass only needed primitive values, not entire objects
- Use clear parameter names that reveal purpose
- Document exact properties when object passing is necessary

**Example**: ✗ Bad: `downloadResume(candidateData, $store, componentInstance)` ✓
Good: `downloadResume(candidateId, candidateName, authToken)`

# Testing

1. Use BDD methodology with GIVEN/WHEN/THEN structure
2. Write descriptive test names that reflect scenarios
3. Use `actual` for test results and `expected` for assertions
4. Test one behavior per test

# Debug

1. Make sure no existing debug command is running.
2. Use `curl -I <dev-server-address>` to test if the dev server is running,
   before you start a new one.
3. Make sure ask user to commit current changes before you run lint or format
   command, avoid making a lot of unexpected changes.

# Shell commands

1. **Search Tools**: Use `fd` for files, `rg` for content (avoid `find` and
   `grep`)
2. **File Operation**: Always provide absolute file paths to MCP tools
3. **Package Managers**: Detect which one to use (npm/pnpm/yarn)
4. **Kill process by port**: `killport <port>`, kill process that owning that
   port
5. **Running shell command**: Detect current shell, use correct shell syntax.
6. **File Changed Between Master/Main**: `jj df-file-base <file-path>`
7. **File Changed Between Prev commit**: `jj df-file-prev <file-path>`

# Error Handling

1. Explicit error propagation is better than silent failure
2. Validate behavior preservation during refactoring
3. Update documentation and tests for significant changes
4. Ask for help when details are needed for decisions
5. Avoid duplicate error messages - prevent multiple layers from showing similar
   user-facing error messages

# Layered Architecture

**Core Principle**: Stable base layer, flexible top layer

Layer definitions:

- Base (foundation): infrastructure, cross-cutting libs, shared contracts/models
- Middle (domain/services, optional): business rules, orchestration, adapters
- Top (interfaces/experiments): UI/CLI, feature flags, mocks/adapters, scripts

1. Layer Impact:

- Base changes have system-wide blast radius — require design review and
  migrations
- Middle changes affect bounded contexts — coordinate with impacted consumers
- Top changes are isolated — preferred for new features and experiments

2. Implementation Strategy:

- Unclear requirements: implement at the top via mocks/adapters; do not touch
  base
- Finalized requirements: modify top/domain code; change base only if a contract
  must evolve
- If base must change: version interfaces, provide migration path, keep old path
  until consumers migrate
- Keep the base complete, well-tested, and minimally changed

3. Decision Framework:

- Solve at the highest possible layer first
- If a base change is unavoidable, record rationale (ADR), risks, and rollback
  plan
- Use interfaces/contracts to decouple layers; prefer adding an adapter over
  altering a base module
- Prefer configuration/feature flags over code changes when feasible

4. Change Checklist:

- What layer am I changing and why?
- Who are the consumers and what is the migration plan?
- Do tests cover contracts at boundaries?
- How will this be monitored/rolled back?
- Does this violate separation of concerns?

5. Anti-patterns:

- Reaching across layers (e.g., UI calling infra directly) bypassing contracts
- Leaking base implementation details into upper layers
- Coupling top-layer features to concrete infra without an interface
