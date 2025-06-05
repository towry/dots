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
- Make function contracts clear
- First ,makethe  code correct, then make it efficient
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
- Constants Over Magic Numbers
  - Replace hard-coded values with named constants
  - Use descriptive constant names that explain the value's purpose
  - Keep constants at the top of the file or in a dedicated constants file
- Meaningful Names
  - Variables, functions, and classes should reveal their purpose
  - Names should explain why something exists and how it's used
  - Avoid abbreviations unless they're universally understood
- Smart Comments
  - Don't comment on what the code does - make the code self-documenting
  - Use comments to explain why something is done a certain way
  - Document APIs, complex algorithms, and non-obvious side effects

## Coding workflow preferences

- Focus on the areas of code relevant to the task
- Do not touch code that is unrelated to the task
- Follow Test-Driven Development (TDD) principles, i.e. start with the test and then implement the code
- Avoid making major changes to the patterns and architecture of how a feature works, after it has shown to work well, unless explicitly instructed
- Always think about what other methods and areas of code might be affected by code changes
- After each code change, commit the changes following conventional commit for the git message

## Testing convention

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


