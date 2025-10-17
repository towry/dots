---
description: Kiro spec driven development
auto_execution_mode: 1
---

# Initial Step: Discover Available Specs

**When `run_command` tool avaiable:**
1. Run `agpod kiro pr-list` with `run_command` tool to automatically list available spec directories.
2. Present the list to the user with numbers for easy reference.
3. Ask user to select which spec they want to work with (by number or name).

**When `run_command` tool not avaiable:**
1. Check for the `llm/kiro` directory in the current project.
2. List all subdirectories under `llm/kiro` to find available specs.
3. Present the list of available specs to the user with numbers for easy reference.
4. Ask user to select which spec they want to work with (by number or name).

# When User Selected a Spec

1. Use fastcontext tool to review the selected `SPEC_dir/claude.md` file.
2. Report the spec's current status and key details.
3. Provide next actionable options based on the spec content.
4. Ask user what they want to do next.

# If User Provides Spec Name Directly

1. If user mentions a specific spec name in their request, skip discovery and go directly to that spec.
2. Verify the spec exists in `llm/kiro/SPEC_NAME/`.
3. Proceed with reading `claude.md` and following the workflow.
