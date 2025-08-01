# Core Principles

1. **Be Direct**: Answer questions directly without unnecessary file modifications
2. **Be Organized**: Use numbered lists for clear referencing
3. **Be Transparent**: List follow-up actions and comment markers (FIXME, TODO, NOTE) when relevant
4. **Be Clear**: Document requirements in comments to ensure mutual understanding
5. **Gather Context**: Always seek sufficient information and clarification before implementing solutions

# Code Safety

1. Never break existing functionality without understanding the impact
2. Only use variables/methods you're certain exist
3. Don't remove code you don't understand
4. Preserve existing code structure and style unless it's flawed
5. Break large tasks into smaller, verifiable steps
6. Check for external dependencies before editing files

# Data & Security

1. Never include sensitive user or machine information in code or comments
2. Prefer dependency injection and localized state over global dependencies
3. Use explicit parameter passing instead of parent component access

# Development Process

1. **Clarify Requirements**: Ask for additional information if tasks are unclear
2. **Validate Requirements**: Identify key requirements and edge cases
3. **Break Down Tasks**: Divide complex tasks into small, manageable steps
4. **Use Comment Markers**: Add FIXME, TODO, NOTE comments for unclear implementations
5. **Consider Scope**: Think about how changes may affect surrounding code

# Code Quality

1. Make function contracts clear
2. Prioritize correctness over efficiency
3. Follow DRY principles but don't religiously follow SOLID
4. Use descriptive constants instead of magic numbers
5. Prefer self-documenting code over comments (except for "why" explanations)
6. Keep files under 2000 lines

# API Design

**Good API Design**:

- Pass only needed primitive values, not entire objects
- Use clear parameter names that reveal purpose
- Document exact properties when object passing is necessary

**Example**:
✗ Bad: `downloadResume(candidateData, $store, componentInstance)`
✓ Good: `downloadResume(candidateId, candidateName, authToken)`

# Testing

1. Use BDD methodology with GIVEN/WHEN/THEN structure
2. Write descriptive test names that reflect scenarios
3. Use `actual` for test results and `expected` for assertions
4. Test one behavior per test

# Tool Usage

1. **Search Tools**: Use `fd` for files, `rg` for content (avoid `find` and `grep`)
2. **File Paths**: Always provide absolute file paths to MCP tools
3. **Verification**: Verify patterns across multiple examples
4. **Package Managers**: Detect which one to use (npm/pnpm/yarn)

# Workflow Preferences

1. **Focus**: Only modify code relevant to the task
2. **Architecture**: Avoid major pattern changes unless instructed
3. **Simplicity**: Use simple solutions and avoid over-engineering

# Error Handling

1. Explicit error propagation is better than silent failure
2. Validate behavior preservation during refactoring
3. Update documentation and tests for significant changes
4. Ask for help when details are needed for decisions
5. Avoid duplicate error messages - prevent multiple layers from showing similar user-facing error messages

# LLM Communication Optimization

The user has language barriers, so you should:

1. **Assume Good Intent**

   - Interpret unclear requests charitably
   - Look for the underlying goal even if the wording is imperfect
   - Consider multiple possible interpretations before responding

2. **Ask Clarifying Questions**

   - When user intent is ambiguous, ask specific questions
   - Request examples or additional context when needed
   - Confirm understanding before proceeding with complex tasks

3. **Provide Multiple Interpretations**

   - When a request could mean several things, offer options
   - Explain what you understood and ask for confirmation
   - Show different ways to approach the problem

4. **Focus on Core Intent**

   - Identify the main goal behind the request
   - Don't get stuck on grammatical errors or word choice
   - Look for technical keywords and context clues

5. **Be Patient with Iterations**

   - Expect multiple rounds of clarification
   - Build on previous exchanges to refine understanding
   - Remember context from earlier in the conversation

6. **Use Simple Language in Responses**
   - Respond with clear, simple explanations
   - Avoid complex terminology unless necessary
   - Provide concrete examples to illustrate concepts
