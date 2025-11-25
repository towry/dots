---
name: git
description: "This skill should be used when working with git, triggered by phrase like [git], [git commit], [diff], [push], [check git status], [create git branch], [git worktree], [git sqaush], [review with changes], [review with lifeguard]"
---

# Git/JJ VCS Skill

**Note**: `<skill-base-dir>` refers to the git skill directory containing this SKILL.md file.

## Purpose
Provide specialized workflows for Git and Jujutsu (jj) version control systems with automatic repository detection, command reference lookup, and safe operation practices.

## Trigger Conditions
Activate this skill for VCS tasks involving Git or Jujutsu (jj), such as:
- Checking status, diffs, logs
- Staging, committing, branching/bookmarks
- Pushing, pulling, fetching
- Managing worktrees/workspaces
- Integrating with lifeguard subagent for code reviews
- Repository initialization and configuration

## Repository Detection & Branching Workflow

### Step 1: Detect Repository Type
Run the repository detection script using the Bash tool:

```bash
bash conf/claude-local-marketplace/skills/git/scripts/repo_check.sh
```

**Important**: Execute this command from the repository root (user's current working directory). The script checks for `.jj` or `.git` folders in the current directory.

The script outputs one of three values to stdout:
- `jj` - Jujutsu repository detected (.jj folder exists)
- `git` - Git repository detected
- `no-repo` - No repository found

**Priority**: If both `.jj` folder and `.git` exist (common when jj operates atop git), the script returns `jj` to respect jj-first preference.

### Step 2: Branch to Appropriate Workflow

| Output | Action |
|--------|--------|
| `jj` | Follow **JJ Branch** workflow. Load `conf/claude-local-marketplace/skills/git/references/jj_workflows.md` for core commands and working copy model. |
| `git` | Follow **Git Branch** workflow. Load `conf/claude-local-marketplace/skills/git/references/git_workflows.md` for command syntax. |
| `no-repo` | Proceed to **Repository Initialization** workflow below. |

#### JJ Branch: Conditional Reference Loading
When following the JJ branch, load additional references based on task complexity:

**Always load first:**
- `/Users/towry/.dotfiles/conf/claude-local-marketplace/skills/git/references/jj_workflows.md` - Core commands, working copy model, WIP pattern, filesets

**Load conditionally when needed:**
- **Bookmark operations** (create, track, push, conflicts): Read `/Users/towry/.dotfiles/conf/claude-local-marketplace/skills/git/references/jj_bookmarks.md`
- **Complex history queries** (ranges, filtering, ancestry): Read `/Users/towry/.dotfiles/conf/claude-local-marketplace/skills/git/references/jj_revset.md`
- **Automation/structured output** (CI scripts, release notes): Read `/Users/towry/.dotfiles/conf/claude-local-marketplace/skills/git/references/jj_template.md`

**Reference selection rules:**
- User mentions "bookmark", "track remote", "push bookmark" → Load `jj_bookmarks.md`
- User asks "show commits where...", "filter by author", "range between..." → Load `jj_revset.md`
- User requests "JSON output", "custom format", "parse for script" → Load `jj_template.md`
- Multiple file path filtering (globs, exclude patterns) → Already covered in `jj_workflows.md` (Fileset section)

#### Git Branch: Reference Loading
- Load `<skill-base-dir>/references/git_workflows.md` for all Git operations (covers branches, worktrees, stashing, troubleshooting)

### Step 3: Repository Initialization (if no-repo)
1. Use `AskUserQuestion` tool to ask: "No repository found. Initialize jj or git?"
   - Options: "jj (recommended)", "git"
   - header: "VCS choice"
2. Based on user selection:
   - **jj**: Run `jj init` or `jj git init` (if git backend desired), then load `references/jj_workflows.md`
   - **git**: Run `git init`, then load `references/git_workflows.md`
3. After initialization, proceed with original user intent

## Common Workflows
Handle user intent with these steps, adapting commands per VCS branch:

### 1. Show Status/Diff
- **JJ**: `jj --no-pager status` for status; `jj --no-pager diff` for unstaged changes
- **Git**: `git status` for status; `git diff` for unstaged; `git diff --staged` for staged changes
- Always gather diff output via `Bash` tool BEFORE invoking other tools

### 2. Review Changes with Lifeguard
- First collect diff/changes using step 1
- Launch `Task` tool with `subagent_type: "lifeguard"` providing the diff content
- For large diffs (>500 lines), chunk review by file or use grep to extract relevant sections
- Lifeguard natively supports git; for jj, provide context that jj commands were used

### 3. Stage Changes
- **JJ**: `jj` auto-tracks all changes in the working copy (no explicit staging needed)
- **Git**: `git add <files>` or `git add .` for all

### 4. Commit Changes
- **CRITICAL**: NEVER commit without explicit user confirmation
- Before committing: Show summary of changes and ask user to confirm
- **JJ**: Check status with `jj --no-pager status` first, then `jj commit -m "message"` or `jj describe -m "message"`
- **Git**: `git commit -m "message"`
- Follow project commit message conventions if documented

### 5. Show History/Logs
- **JJ**: `jj --no-pager log` or `jj --no-pager log -n 10` for limited entries
- **Git**: `git log` or `git log --graph --oneline --all`

### 6. Create Branch/Bookmark
- **JJ**: `jj bookmark create <name>` then `jj edit <bookmark>` to work on it
- **Git**: `git checkout -b <name>` or `git switch -c <name>`

### 7. Push to Remote
- **CRITICAL**: NEVER push without explicit user confirmation
- Check branch tracking status first
- **JJ**: `jj git push` (pushes current bookmark)
- **Git**: `git push origin <branch>` or `git push -u origin <branch>` for first push
- NEVER use `--force` unless explicitly requested by user

### 8. Worktree/Workspace Management
- **JJ**: `jj workspace add <path>` creates new workspace
- **Git**: `git worktree add <path> <branch>` creates new worktree
- See reference files for list/remove commands

## Conceptual Differences Between JJ and Git

| Concept | Git | Jujutsu (jj) |
|---------|-----|--------------|
| **Staging** | Explicit index (`git add`) | Automatic working copy tracking |
| **Branch concept** | `refs/heads/<name>` pointers | Bookmarks (lightweight refs) |
| **History model** | Mutable (rebase/amend) | Immutable DAG (creates descendants) |
| **Working state** | Working dir + index + HEAD | Working copy commit |
| **Conflicts** | Block operations | First-class objects, can commit |

**Important**: JJ often operates atop a git backend (`.jj` + `.git` coexist). When both present, prefer jj commands but be aware git operations may affect jj state.

## Examples

### Example 1: Review unstaged changes
```
User: please check unstaged changes and review with lifeguard subagent
```

Workflow:
1. Run `scripts/repo_check.sh` → Output: `jj`
2. Run `jj diff` (consult `references/jj_workflows.md` for syntax)
3. Capture diff output
4. Launch `Task(subagent_type: "lifeguard")` with diff content in prompt
5. Report lifeguard findings to user

Note: For git repos, use `git diff` instead in step 2.

### Example 2: New worktree/workspace for feature
```
User: I'd like to work on this feature in a new worktree/workspace
```

Workflow:
1. Run `scripts/repo_check.sh` → Determine VCS type
2. Ask user for workspace/worktree name and branch (if needed)
3. Execute appropriate command:
   - **JJ**: `jj workspace add <path>`
   - **Git**: `git worktree add <path> <branch>` (branch must exist or be created)
4. Confirm creation with `jj workspace list` or `git worktree list`
5. Inform user of new workspace location

### Example 3: Commit workflow with safety
```
User: commit these changes
```

Workflow:
1. Run `<skill-base-dir>/scripts/repo_check.sh` → Determine VCS type
2. Show current status/diff
3. **For JJ branch**:
   - Run `jj --no-pager status` to check working copy state
   - Check if working copy is empty and parent commit has "WIP:" description
   - If WIP commit detected, ask user: "Parent commit is WIP. Options:"
     - "Squash into WIP" → `jj squash` (amend changes to WIP commit)
     - "Create new commit" → `jj commit -m "<message>"`
     - "Edit WIP description" → `jj describe -r @- -m "<new message>"`
   - If working copy has changes with no description: `jj describe -m "<message>"` first
   - If working copy is ready: proceed to step 4
4. **ASK USER**: "Commit with message: '<suggest message>'? Proceed?"
5. Only if user confirms:
   - **JJ**: `jj commit -m "<message>"` (creates new commit, moves working copy)
   - **Git**: `git add .` then `git commit -m "<message>"`
6. Show commit result with `jj log -n 2` or `git log -1`

**Note**: JJ's commit semantics differ from Git. Always check status first to avoid committing empty working copy. See `references/jj_workflows.md` for WIP pattern details.

## Safety Guidelines

### Critical Rules
1. **NEVER commit or push without explicit user confirmation**
2. **NEVER use force push** (`git push --force`, `jj git push --force`) unless user explicitly requests it
3. **ALWAYS verify branch/bookmark** before pushing to prevent accidental pushes to main/master
4. **For large operations**: Use `TodoWrite` to track multi-step workflows

### Pre-Commit Checks
- Verify you're not on protected branch (main, master, staging, production)
- Show summary of what will be committed
- Suggest meaningful commit message following project conventions
- Wait for explicit user approval

### Pre-Push Checks
- Check remote tracking status: `git status` or `jj status`
- Show what will be pushed: commits ahead of remote
- Verify target branch/bookmark is correct
- Wait for explicit user approval

## Integration Notes
- **Project preference**: Favor `jj` when available (per user Claude config)
- **TodoWrite usage**: Use for multi-step VCS workflows (e.g., feature branch creation → changes → commit → push)
- **Reference file loading**: Load `references/jj_workflows.md` or `references/git_workflows.md` only when command syntax is uncertain
- **Lifeguard integration**: Provide VCS context when invoking (e.g., "using jj diff output")

## Future Enhancements (TODO)
- Add conflict resolution workflows (`jj resolve`, `git mergetool`)
- Add rebase/history editing patterns
- Add cherry-pick equivalents (jj: `duplicate` command)
- Add bisect workflow (git native; jj: manual narrowing strategy)
- Add branch/bookmark cleanup scripts
- Add commit message linting integration
