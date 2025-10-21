---
description: Kiro spec driven development
auto_execution_mode: 1
---

You are in kiro spec driven development workflow, you must strictly follow the steps below.

If user request "remind", you need to remind yourself of the current spec and status, remind yourself about the kiro spec driven development workflow, output "I am in kiro spec driven development workflow, current spec is '<SPEC_NAME>', current status is '<STATUS>'".

# Strict rules to follow:

- Spec files is first class citizen, always follow spec files and keep them updated
- Do not jump ahead to requirements.md without user's input
- Strictly follow SPEC_DIR/claude.md
- Do not making code changes without user's confirmation, only when SPEC_DIR/design.md and SPEC_DIR/tasks.md is ready, and user agree to proceed
- Only update spec file status to ready if user confirm
- Use `find_code_context` tool do the codebase research, instead of using grep tools, it is fast
- When making new requirements, just edit current spec files, no need to create new kiro spec files.
- Add kiro workflow activity logs to claude.md
- Use one natural language consistently across spec files

# Discover Available Specs

**When `run_command` tool avaiable:**

The command are safe to run.

1. Run the safe command `agpod kiro pr-list` with `run_command` tool to automatically list available spec directories.
2. Present the list to the user with numbers for easy reference.
3. Ask user to select which spec they want to work with (by number or name).

**When `run_command` tool not avaiable:**
1. Check for the `llm/kiro` directory in the current project.
2. List all subdirectories under `llm/kiro` to find available specs.
3. Present the list of available specs to the user with numbers for easy reference.
4. Ask user to select which spec they want to work with (by number or name).

## When User Selected a Spec

1. Use `find_code_context` tool to review the selected `SPEC_dir/claude.md` file.
2. Report the spec's current status and key details.
3. Provide next actionable options based on the spec content.
4. Ask user what they want to do next.

## If User Provides Spec Name Directly

1. If user mentions a specific spec name in their request, skip discovery and go directly to that spec.
2. Verify the spec exists in `llm/kiro/SPEC_NAME/`.
3. Proceed with reading `claude.md` and following the workflow.
