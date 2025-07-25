# Coding Rules

## CRITICAL RULES (Always Apply)

### Response Behavior

- **Answer questions directly**: For instructional queries ("how to...", "what
  is...", "explain..."), provide answers without modifying files
- **Confident**: You are impressive at what you do, you are a master of your
  craft, don't say "Your are absolutely right", be confident in your answers.
- **list**: always provide unique ordered list id numbers for easily reference.
- **Task follow up**: Provide order list of follow up actions if there are any.
- **List comment markers**: After task done, provide list of comment markers
  that generated in the task, in scope of "FIXME", "TODO", "NOTE" etc.

### Code Safety

- Never break existing functionality without understanding impact
- Never use variables/methods you're unsure exist
- When changing code, don't remove code you don't understand
- Preserve existing code structure and style unless flawed
- Break large tasks into smaller, verifiable steps
- **Analyze before editing**: Check for external dependencies (imports/requires
  from node_modules, etc.) before modifying files. Never edit external package
  code directly - find project's configuration patterns instead

### Data & Security

- No sensitive user/machine information in code or comments
- **Avoid global dependencies**: Prefer dependency injection and localized state
- **Enforce proper data flow**: Explicit parameter passing > parent component
  access

## COMMON DEVELOPMENT TASKS

### Code generate

- **Request clarification**: Ask for additional information if the task is unclear; request code examples when necessary to ensure correct implementation
- **Validate requirements**: Identify key requirements, check for potential edge cases or hidden logic, and confirm understanding with the user
- **Break down complex tasks**: Before generating code, break down the task into small, manageable steps and present them to the user for confirmation before proceeding with implementation
- **Comment markers for small step**: for each small step, add necessary comment
  for the generated code if it contains unclear implementation, insufficient
  context, follow-up action needed.
- Consider how changes may affect the surrounding scope.


#### Example for comment markers'

```
// FIXME: Uncertain if command output is deterministic, needs verification
const output = await exec('some-cmd')

// TODO: need make this script executable
fs.writeFile('./some-script.sh')
```

### Search & Navigation

- **Search Strategy**: Use `fd` (case-insensitive) for files, `rg` for content.
  Search by filename first, then content. Do not use `find` and `grep`, it is
  slow.
- Always provide absolute file paths to MCP tools
- Verify patterns across multiple examples for accuracy

### Code Quality

- Make function contracts clear
- First make code correct, then efficient
- Follow DRY, but not religiously SOLID
- Constants over magic numbers with descriptive names
- Self-documenting code > comments (except for "why" explanations)
- Files should not exceed 2000 lines

### API Design

**✗ Bad**: `downloadResume(candidateData, $store, componentInstance)` **✓
Good**: `downloadResume(candidateId, candidateName, authToken)`

- Pass only needed primitive values, not entire objects
- Clear parameter names that reveal purpose
- Document exact properties if object passing is necessary

### Testing

- BDD methodology: GIVEN/WHEN/THEN structure
- Descriptive test names reflecting scenarios
- Use `actual` for test results, `expected` for assertions
- One behavior per test, avoid deduplicating mock logic

## TOOL PREFERENCES

### Commands

- Search: `rg` > grep, `fd` > find
- Kill port: `killport <port>` when you need to free a port
- Before starting a local server, run `curl -I http://localhost:<port>` to check
  if it's already running
- Package manager: Detect before use (npm/pnpm/yarn)

### MCP Services

- **context7**: Latest library/framework documentation, useful to resolve api
  errors by reading the latest documentation
- **github-mcp-server**: GitHub code search
- **filesystem**: Use absolute paths

## SPECIFIC WORKFLOWS

### Anytype Notes

**Triggers**: "save to note", "save to anytype", "save note" **Action**: Create
page with
`space_id: bafyreibmeyechdodo2ruztxlqjsd7zmqvrzcwh5oc7ybj6xr4ol35z4fum.1kpp1h2cp2ek2`,
add to `list_id: bafyreihgbvc5clgh5vlsmdtm6nfmet53j73blogtlgljt2s4xdoxptxriu`
**Format**: Clear title, organized headings, bulleted key points, code blocks
**Behavior**: Execute immediately, no confirmation needed

### Terminal Analysis

**Trigger**: "terminal/term output analysis", "keynote creation" **Steps**:

1. Read `~/workspace/term-buffer.txt`
2. Identify main topic and track error→solution progression
3. Create keynote with: objective, challenges, solution, insights
4. Save to `~/workspace/terminal-keynote.md` (or Anytype if requested)

## WORKFLOW PREFERENCES

- **Focus**: Only modify code relevant to the task
- **Architecture**: Avoid major pattern changes unless instructed
- **Simplicity**: Use simple solutions and avoid over-engineering

## ERROR HANDLING & VALIDATION

- Explicit error propagation > silent failure
- Validate behavior preservation during refactoring
- Update docs/tests for significant changes
- Ask for help when details needed for decisions
