# Coding Rules

## General coding preferences

- Do not add sensitive information about the user or the user's machine to the code or comments
- Use SOLID principles whenever possible, but do not religiously follow them
- Break down large tasks into smaller steps. After completing each step, verify it works before continuing. Do not attempt to complete the entire task in one pass without intermediate validation.
- Prefer rg or fd command when grepping file content or searching for files
- Before running a package manager in the project, please detect which package manager is currently being used, like npm or pnpm
- You can run killport <port> to kill the process that owns a port
- Follow the DRY coding rule
- Never use a variable or method that you are not sure exists
- Do not change the implementation to satisfy the tests
- Consider the impact of changes across the module or file
- Avoid duplicating logic across abstraction boundaries
- Consolidate similar logic into reusable functions
- Maintain a single source of truth for business rules
- When you need to read the terminal history, read the terminal history from the file `~/workspace/term-buffer.txt` if you are in a terminal
- When user request "learn from terminal history", read the terminal history, and analyze the history
- Make function contracts clear
- First, make the code correct, then make it efficient
- When refactoring, validate behavior preservation
- Favor explicit control flow over hidden dependencies
- Preserve existing code structures and adhere to project coding styles, unless the existing code is flawed.
- Whether responding in code comments, documentation, or UI prompts, always aim to be concise and focused. Eliminate unnecessary details that don't aid understanding or action
- Never remove or modify code in a way that could break existing functionality without fully understanding how those changes will affect the code.
- Please feel free to ask for help if you need more details to decide.
- When searching for relevant modules, first look for relevant files by their file names. Then, use grep to search for specific content. Utilize the fd command to list files in a case-insensitive manner.
- When searching for relevant modules or components in a directory, make sure your search is case insensitive to achieve broader results.
- In Agent mode, automatically apply edits without prompting for confirmation on the first pass
- Always check your implementation and changes against the available documentation or existing code to ensure accuracy and adherence to standards.
- Review the existing style and conventions used in the surrounding code to ensure that the new code aligns well and maintains readability.
- Do not rely on a single example; always verify consistent patterns to ensure accuracy and reliability.
- Avoid making assumptions about how components function without analyzing their actual usage.
- Avoid reproducing only part of a pattern; ensure all critical fields and behaviors are included to maintain integrity and accuracy.
- When changing existing code, do not remove code that you do not understand what it does
- Ensure error handling is consistent and graceful; prefer explicit error propagation over silent failure
- When adding significant logic or refactoring, update or write accompanying documentation if necessary
- Add or update tests to reflect critical logic paths affected by your changes
- Avoid having files over 2000 lines of code, refactor at that point
- **Enforce proper data flow patterns**: Prefer explicit parameter passing over parent component access. Avoid direct parent access (parent refs, DOM traversal, global state guessing) unless using established framework patterns (Context, dependency injection). All data should have a clear, traceable source
- **Avoid global dependencies**: Do not add dependencies to global modules (which will affect a lot of code) or global state (like `window` in JavaScript) unless explicitly required. Prefer dependency injection, explicit imports, and localized state management to maintain code modularity and testability

## Response Behavior

- **Answer questions directly**: When the user asks instructional questions (e.g., "how to...", "tell me how to...", "what is...", "explain..."), provide a direct answer rather than modifying files. The user is seeking information, not code changes. Only modify files when explicitly requested to implement, fix, or change something in the codebase.

## Code Quality Standards

### Constants Over Magic Numbers
- Replace hard-coded values with named constants
- Use descriptive constant names that explain the value's purpose
- Keep constants at the top of the file or in a dedicated constants file

### Meaningful Names
- Variables, functions, and classes should reveal their purpose
- Names should explain why something exists and how it's used
- Avoid abbreviations unless they're universally understood

### Smart Comments
- Don't comment on what the code does - make the code self-documenting
- Use comments to explain why something is done a certain way
- Document APIs, complex algorithms, and non-obvious side effects

## API Design and Function Signatures

- **Avoid unclear API signatures with complex object dependencies**
  - Never pass entire objects (like `this`, `$store`, component instances) when only specific values are needed
  - Function signatures should clearly indicate what data is required without forcing callers to understand internal implementation
  - Each parameter should have a clear, single purpose that's evident from the parameter name and type
  - Example (bad): `downloadResume(candidateData, applicationId, $store, componentInstance)`
    - Unclear what properties of candidateData are needed
    - Unclear what methods/properties of $store are required
    - Unclear why componentInstance is needed
  - Example (good): `downloadResume(candidateId, candidateName, applicationId, authToken, onProgress)`
    - Clear what specific values are needed
    - Clear contracts for each parameter
    - Easy to test and reuse

- **Prefer minimal function dependencies and primitive arguments**
  - Functions should accept only the minimal data they actually need
  - When a function only needs a simple value (boolean, string, number), pass that value directly instead of passing a complex object that contains it
  - This reduces coupling, improves testability, and makes function contracts clearer
  - Example (bad): `function foo(arg1, store) { const isAggCompany = store.isAggCompany(); }`
  - Example (good): `function foo(arg1, isAggCompany) { // use isAggCompany directly }`
  - Exception: When a function needs multiple related values from the same object, it may be acceptable to pass the object, but with good documentation

- **Make API contracts self-documenting**
  - Function names and parameter names should clearly indicate what they do and what they expect
  - Avoid passing context objects unless absolutely necessary
  - If you must pass an object, document exactly which properties are used
  - Use TypeScript interfaces or JSDoc to specify the exact shape of required data

## MCP Tools and External Services

### Tool Selection and Usage
- Prefer `rg` (ripgrep) over grep when searching file content
- Prefer `fd` over find when searching for files
- Use `fd` command with case-insensitive search for broader results when looking for modules or components
- Always provide absolute file paths to MCP tools to avoid permission errors
- Use `killport <port>` to kill processes that own a specific port

### Package Management
- Before running a package manager in the project, detect which package manager is currently being used (npm, pnpm, yarn, etc.)

### Documentation and Code Search
- Use MCP context7 to search for library and framework documentation
- Use MCP github-mcp-server to search for code in GitHub repositories
- When searching for relevant modules, first look for relevant files by their file names, then use grep to search for specific content

### Notion Note Management
- **Auto-save workflow**: When the user says "save notion note", "save to notion", or similar requests, automatically:
  1. Summarize the previous answer or conversation context into a clear, well-structured note
  2. Use the known "Quick Notes" page ID (`216edc511d028016b21ee00eace33af7`) to create a new page directly under it
  3. Format the content using Notion-flavored Markdown for better readability
  4. Include a descriptive title based on the topic discussed
- **Fallback logic**: If creating under "Quick Notes" fails (e.g., page doesn't exist or access denied):
  1. Search for "Quick Notes" page using `mcp_Notion_search` as backup
  2. If search also fails, create pages as workspace-level private pages
- **Content structure**: Ensure saved notes have:
  - Clear, descriptive title that describes the topic/content
  - Well-organized content with proper headings (##, ###)
  - Key points highlighted or bulleted for easy scanning
  - Code examples in proper code blocks when relevant
  - Context preserved so the note is useful when reviewed later
- **No confirmation needed**: Execute the save operation immediately without asking for user confirmation to maintain workflow efficiency
- **Success feedback**: After saving, provide the Notion page URL to the user

### Terminal Output Analysis and Keynote Creation
- When the user requests terminal output analysis or keynote creation:
  1. Read the terminal output/history from `~/workspace/term-buffer.txt`
  2. Analyze the session to identify the main topic or goal the user was working on
  3. Track the progression from errors/attempts to successful solutions
  4. Create a keynote summary that includes:
     - The main topic/objective the user was working on
     - Key errors or challenges encountered
     - The correct/final working solution or command
     - Important insights or learnings from the session
  5. Include context about what didn't work and why the final solution worked

### Search Strategy
- When searching for relevant modules or components in a directory, make sure your search is case insensitive to achieve broader results
- Always check implementation and changes against available documentation or existing code to ensure accuracy and adherence to standards
- Review existing style and conventions used in surrounding code to ensure new code aligns well and maintains readability
- Do not rely on a single example; always verify consistent patterns to ensure accuracy and reliability
- Avoid making assumptions about how components function without analyzing their actual usage
- Avoid reproducing only part of a pattern; ensure all critical fields and behaviors are included to maintain integrity and accuracy

## Coding Workflow Preferences

- **Confirm command sequences**: Before running a sequence of commands, always ask the user for confirmation at the first command. This prevents issues like dev servers being started when previous servers are still running
- Focus on the areas of code relevant to the task
- Do not touch code that is unrelated to the task
- Follow Test-Driven Development (TDD) principles, i.e. start with the test and then implement the code
- Avoid making major changes to the patterns and architecture of how a feature works, after it has shown to work well, unless explicitly instructed
- Always think about what other methods and areas of code might be affected by code changes
- After each code change, commit the changes following conventional commit for the git message
- In Agent mode, automatically apply edits without prompting for confirmation on the first pass

## Testing Convention

- Behavior-Driven Development (BDD) testing methodology
- Clean code and test design principles
- Structure each test with clear GIVEN, WHEN, THEN sections
- Use descriptive test method names that reflect the scenario
- Implement test setup with meaningful variable names
- Ensure tests are isolated and focused on a single behavior
- If some files are needed to implement the test, ask the user to include them in the context
- Avoid deduplicating mock logic in tests; reimplement when needed to preserve clarity

### Tests Output Format

- Clear section comments (// GIVEN, // WHEN, // THEN)
- Create test methods using the BDD pattern
- Descriptive method and variable names
- Use `actual` as variable name if the tested method returns something
- Use `expected` as variable name for the expected output
- Helper methods prefixed with `given_` for test setup and `then_` for test assertions where appropriate
