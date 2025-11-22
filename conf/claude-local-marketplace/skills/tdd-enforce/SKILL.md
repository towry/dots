---
name: tdd-enforce
description: Enforce Test-Driven Development (TDD) workflow for implementation tasks
---

# Description

The TDD workflow ensures high-quality implementation by enforcing a cycle of writing tests before code. This skill guides the agent to break down implementation tasks into small, verifiable steps, ensuring each step is verified by a test before moving forward.

# When to use this skill

- When the user asks to "implement" a feature or function.
- When the user agrees to a plan that involves coding.
- When you are about to use the `TodoWrite` tool for a coding task.
- When the user explicitly mentions "TDD" or "test driven".

# Process

1. **Plan with Todos**: Before coding, create a `TodoWrite` list where every implementation step is paired with a verification step (test).
2. **Red (Write Test)**: Create or update a test case that defines the expected behavior for the next small unit of work. Run it to confirm it fails (or verify it doesn't exist yet).
3. **Green (Implement)**: Write the minimum code necessary to pass the test.
4. **Verify**: Run the test again to confirm it passes.
5. **Refactor (Optional)**: Clean up the code if needed, ensuring tests still pass.
6. **Repeat**: Mark the todo item as done and move to the next pair of Test/Implement steps.

# Examples

## Example Todo List Structure

When implementing a `RealInfluxClient`:

```text
Todos:
1. RED: Write integration test for RealInfluxClient.health() with testcontainers
2. GREEN: Implement RealInfluxClient.health() to make test pass
3. VERIFY: Run test and ensure it passes
4. RED: Write integration test for RealInfluxClient.write_tick()
5. GREEN: Implement RealInfluxClient.write_tick()
6. VERIFY: Run test and ensure it passes
7. RED: Write integration test for RealInfluxClient.query_ticks()
8. GREEN: Implement RealInfluxClient.query_ticks()
9. VERIFY: Run test and ensure it passes
```

## Example Interaction

**User**: "Implement a function to reverse a string."

**Agent**: "I will use TDD to implement this. I'll start by creating a plan."

*Calls `TodoWrite`*:
1. RED: Create test case `test_reverse_hello` expecting "olleh"
2. GREEN: Implement `reverse_string` function to pass the test
3. VERIFY: Run tests to verify

**Agent**: "I've created the plan. First, I'll write the failing test."
*Writes test, runs it (fails)*.
"Now I will implement the logic."
*Writes code, runs test (passes)*.

