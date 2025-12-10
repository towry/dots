---
name: kiro
description: "This skill should be used when managing structured spec-driven development workflows. Triggered by phrases like [kiro], [check kiro status], [load kiro], [update kiro], [kiro workflow], or when the user mentions kiro spec, create new kiro spec. Use this for managing requirements, design docs, and implementation tasks in kiro"
---

# Kiro - Structured Spec-Driven Development Workflow

## Output style

- No extra explanations, only respond with the requested content
- If workflow decisions is clear, just do it, no additional confirmation, explanations or summary needed, avoid bloating the context before actual work.

## Overview

Kiro is a workflow management system for structured spec-driven development that uses spec files to track progress through requirements gathering, design, and implementation phases. This skill enables Claude to manage the complete lifecycle of a kiro spec, from initial requirements to final implementation.

The kiro spec dir default to <project-root>/llm/kiro/<spec-name>/ but can be customized per spec.

## Core Workflow Structure

Every kiro spec contains four key spec files, which need to be updated and tracked throughout the workflow:

1. **`claude.md`** - Control board with session notes, decisions, and spec status tracking
2. **`requirements.md`** - User stories and acceptance criteria
3. **`design.md`** - Architecture, data models, and implementation details
4. **`tasks.md`** - Implementation tasks with status tracking
5. **`review-spec.md`** - Document as a bridge for user and the spec owner, help to review this spec before implement.

## Workflow Decision Tree

When user mentions kiro, follow this decision tree:

1. **Does the user want to create a new kiro spec?**
   - Keywords: "new kiro", "create kiro spec", "start new kiro"
   - Action: Run `agpod kiro pr-new --desc "<description>" --template default`

2. **Does the user want to select/load an existing spec?**
   - Keywords: "load kiro", "check kiro", "select kiro", "which kiro"
   - Action: If current kiro dir exist in system prompt, continue with that kiro spec. Otherwise, ask `eng` subagent to provide existing specs.

3. **Is the user already working on a spec?**
   - Action: Continue with the current workflow phase

## Phase 1: Loading a Kiro Spec

### Step 1: Select the Kiro Spec

Check our system prompt, if our system prompt have existing kiro dir <kiro_dir>, just load it. Otherwise, follow these steps:

Ask subagent `eng` to run the following command to get all kiro specs:

```bash
agpod kiro --json pr-list
```

**Expected JSON output format:**
```json
[
  {
    "name": "spec-name",
    "path": "<spec-path>",
    "created": "2024-01-15T10:30:00Z"
  }
]
```

Note, the `path` should be relatieve to the project root or is absolute path if it starts with `/`.

Present the list of specs to the user and ask which one to load, or select based on user input.

### Step 2: Read the Control Board

Once spec is selected, read `<spec-path>/claude.md` to understand:
- Current spec file statuses (empty, draft, ready)
- Previous decisions made
- Outstanding questions and risks
- Recent findings

## Phase 2: Requirements Gathering

**When to enter this phase:**

- `claude.md` shows `requirements.md: empty` or `requirements.md: draft`

### Workflow

1. **Read current requirements**
   ```bash
   Read <spec-path>/requirements.md
   ```

2. **Gather requirements from user**
   - Ask clarifying questions about user stories
   - Define acceptance criteria with WHEN/THEN format
   - Document each requirement using semantic IDs (e.g., REQ-AUTH-LOGIN, REQ-DATA-EXPORT)
   - Use pattern: REQ-{DOMAIN}-{ACTION} for stable, descriptive identifiers
   - Add all requirement IDs to the "Requirements Order" section at the top of requirements.md

3. **Update requirements.md**
   - Add user stories in format: "As a [role], I want to [action], so that [benefit]"
   - Define acceptance criteria for each requirement
   - Follow the existing structure already present in the generated `requirements.md` file

4. **Update claude.md status**
   - Change `requirements.md: draft` when in progress
   - Change to `requirements.md: ready` when complete and approved
   - Document key decisions in Session Notebook → Decisions

**Critical Rule:** Never proceed to design phase without user approval of requirements.

## Phase 3: Design Documentation

**When to enter this phase:**
- `claude.md` shows `requirements.md: ready` AND `design.md: empty` or `design.md: draft`

### Workflow

1. **Read current design and requirements**
   ```bash
   Read <spec-path>/design.md
   Read <spec-path>/requirements.md
   ```

2. **Create design for each requirement**

   For each requirement ID (e.g., REQ-AUTH-LOGIN), create a corresponding design section with:

   - **Overview**: Purpose, key objectives, non-goals
   - **Architecture**: System design diagrams, data flow
   - **Components and Interfaces**: Component responsibilities
   - **Data Models**: Configuration, data structures, API contracts
   - **Implementation Details**: Algorithms, PoC findings (if needed)
   - **Performance & Security Considerations**
   - **Error Handling**: Error scenarios and strategies
   - **Testing Strategy**: Unit and integration tests
   - **Migration and Rollout**: Deployment strategy (if needed)

3. **Present design options**
   - Offer multiple approaches when applicable
   - Explain trade-offs clearly
   - Let user choose the preferred approach
   - Ask oracle subagent with `Task` tool to review the design

4. **Update design.md**
   - Follow the existing structure already present in the generated `design.md` file
   - Include ASCII diagrams for system architecture
   - Keep it focused and scannable

5. **Update claude.md**
   - Change `design.md: draft` when in progress
   - Change to `design.md: ready` when complete and approved
   - Document design decisions in Session Notebook → Decisions
   - Note any identified risks in Session Notebook → Risks

**Critical Rule:** Never proceed to implementation without user approval of design.

## Phase 4: Task Planning

**When to enter this phase:**
- `claude.md` shows `design.md: ready` AND `tasks.md: empty` or `tasks.md: draft`

### Workflow

1. **Read design and create tasks**
   ```bash
   Read <spec-path>/design.md
   Read <spec-path>/tasks.md
   ```

2. **Break down each requirement into tasks**

   For each requirement ID (e.g., REQ-AUTH-LOGIN), create corresponding TASK-REQ-{ID} section (e.g., TASK-REQ-AUTH-LOGIN) with:

   - **Phases**: Group related tasks (e.g., Phase 1: Core Implementation, Phase 2: Integration)
   - **Task details** for each item:
     - Checkbox for completion tracking
     - **Status**: ⬜ Not Started / 🟡 In Progress / ✅ Completed / ⚠️ Blocked
     - **Prompt**: Detailed implementation instructions
     - **Requirements**: Reference to requirement ID (e.g., REQ-AUTH-LOGIN)
     - **Design ref**: Section reference in design.md
     - **Files**: List of files to modify

3. **Update tasks.md**
   - Follow the existing structure already present in the generated `tasks.md` file
   - Keep tasks atomic and independently executable
   - Order tasks by dependencies

4. **Update claude.md**
   - Change `tasks.md: draft` when in progress
   - Change to `tasks.md: ready` when complete and approved

**Critical Rule:** Never start implementation without user approval of tasks.

## Phase 5: Implementation

**When to enter this phase:**
- `claude.md` shows `tasks.md: ready`
- User explicitly requests code changes

### Workflow

1. **Read tasks and select next task**
   ```bash
   Read <spec-path>/tasks.md
   ```

2. **Confirm task with user**
   - Show which task will be implemented
   - Verify user approval before coding

3. **Implement the task**
   - Follow the prompt in the task definition
   - Reference the design document
   - Verify requirements are met

4. **Update task status**
   - Mark task as 🟡 In Progress when starting
   - Update checkbox `[x]` when complete
   - Change status to ✅ Completed
   - Document any findings in `claude.md` → Session Notebook → Findings

5. **Update claude.md after each task**
   - Add any new decisions to Session Notebook → Decisions
   - Note any risks encountered
   - Keep spec file status current

## Critical Rules (Always Enforce)

1. **Status Tracking**: Keep the "Spec files status" section in `claude.md` current at all times
2. **Never Skip Approval**: Never proceed to next phase without explicit user approval
3. **Always Ask Questions**: When requirements are unclear, ask rather than assume
4. **Present Options**: Offer choices for user to decide rather than making assumptions
5. **Only Edit Code When Requested**: Research and planning phases should not modify code
6. **Document Decisions**: Update Session Notebook → Decisions whenever user makes a choice
7. **Task Checkboxes**: All tasks must have checkboxes for completion tracking
8. **Sync Updates**: Update `claude.md` immediately after changes to other spec files

## Status Values

Spec files can have three statuses:
- **empty**: File is template/placeholder, not yet filled
- **draft**: Work in progress, not approved
- **ready**: Complete and approved by user

## Useful Commands

### List all kiro specs
```bash
agpod kiro --json pr-list
```

### Create new kiro spec
```bash
agpod kiro pr-new --desc "<description>" --template default
```

Additional options:
- `--git-branch`: Create and checkout git branch
- `--open`: Open in editor after creation
- `--force`: Force creation even if directory exists

To list templates, run `agpod kiro --json list-templates`


## Example

user: "load kiro system spec" / "load kiro system"
agent: "Loading kiro skill ... I see user mention 'system', let  me ask `eng` subagent to list existing kiro specs and see if a matching 'system' spec exist ... Ok let me read this spec and check the control board for current status ... I see requirements.md is empty, so we need to gather requirements ..."
