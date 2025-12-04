---
name: git-jj
description: "Used when working with vcs/git/jj/commit task, triggered by phrase like [git], [git commit], [diff], [push], [check git status], [create git branch], [git worktree], [git sqaush], [review with changes], [review with lifeguard], [jj], [jj commit], [jj changes], [commit changes]"
---

# Git/JJ VCS Skill

**Note**: 

- `<skill-base-dir>` refers to the git skill directory (~/.claude/skills/git-jj/) containing this SKILL.md file.
- When committing, the commit message must follow the "Conventional Commits" format: `<type>(<scope>): <description>`

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
bash ~/.claude/skills/git-jj/scripts/repo_check.sh
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
| `jj` | Follow **JJ Branch** workflow. Read `~/.claude/skills/git-jj/references/jj_workflows.md` for core commands and working copy model. |
| `git` | Follow **Git Branch** workflow. Read `~/.claude/skills/git-jj/references/git_workflows.md` for command syntax. |
| `no-repo` | Proceed to **Repository Initialization** workflow below. |

#### JJ Branch: Conditional Reference read

When following the JJ branch, load additional references based on task complexity:

**Always read first:**

- `~/.claude/skills/git-jj/references/jj_workflows.md` - Core commands, working copy model, WIP pattern, filesets

**Read conditionally when needed:**
- **Bookmark operations** (create, track, push, conflicts): Read `~/.claude/skills/git-jj/references/jj_bookmarks.md`
- **Complex history queries** (ranges, filtering, ancestry): Read `~/.claude/skills/git-jj/references/jj_revset.md`
- **Automation/structured output** (CI scripts, release notes): Read `~/.claude/skills/git-jj/references/jj_template.md`

**Reference selection rules:**
- User mentions "bookmark", "track remote", "push bookmark" → Load `jj_bookmarks.md`
- User asks "show commits where...", "filter by author", "range between..." → Load `jj_revset.md`
- User requests "JSON output", "custom format", "parse for script" → Load `jj_template.md`
- Multiple file path filtering (globs, exclude patterns) → Already covered in `jj_workflows.md` (Fileset section)

#### Git Branch: Reference Loading
- Read `<skill-base-dir>/references/git_workflows.md` for all Git operations (covers branches, worktrees, stashing, troubleshooting)

### Step 3: Repository Initialization (if no-repo)
1. Use `AskUserQuestion` tool to ask: "No repository found. Initialize jj or git?"
   - Options: "jj (recommended)", "git"
   - header: "VCS choice"
2. Based on user selection:
   - **jj**: Run `jj init` or `jj git init` (if git backend desired), then load `references/jj_workflows.md`
   - **git**: Run `git init`, then load `references/git_workflows.md`
3. After initialization, proceed with original user intent

## Common Workflows

For command syntax, see reference files. This section covers workflow orchestration.

### 1. Show Status/Diff
- Always gather diff output via `Bash` tool BEFORE invoking other tools
- See `jj_workflows.md` or `git_workflows.md` for commands

### 2. Review Changes with Lifeguard
- Run `scripts/repo_check.sh` first to confirm VCS type.
- Git workflow (small diff <500 lines): you MAY embed the git diff directly. For larger diffs, prefer letting lifeguard fetch them itself.
- JJ workflow (preferred): DO NOT paste full `jj diff` output unless very small (<200 lines). Instead launch the lifeguard subagent with an execution plan listing jj commands it should run to gather its own context.
- Rationale: JJ diffs can be large and lifeguard has Bash(jj:*) capability; letting it execute jj commands avoids prompt bloat and enables multi‑commit exploration.
- Skill loading directive: In every lifeguard prompt include either (a) explicit phrase: `please load git claude skill` (this triggers skill reference loading), OR (b) inline list of reference file paths you want it to consult. Prefer phrase for brevity; attach paths when focusing on specialized areas (revsets, bookmarks, templates).

Reference file path list

- ~/.claude/skills/git-jj/references/git_workflows.md
- Read ~/.claude/skills/git-jj/references/jj_workflows.md (when commit changes, logs, review with jj etc)
- ~/.claude/skills/git-jj/references/jj_bookmarks.md
- ~/.claude/skills/git-jj/references/jj_revset.md
- ~/.claude/skills/git-jj/references/jj_template.md

Use this canonical jj command set in the lifeguard prompt (adjust as needed):

```
# Core context collection
jj --no-pager status
jj --no-pager log -n 20 --no-graph
jj --no-pager diff          # working copy changes

# Targeted commit review (replace <rev>)
jj --no-pager show <rev>

# Compare parent vs current working copy commit
jj --no-pager diff -r @-..@

# Multi-commit / ancestry exploration examples
jj --no-pager log -r "ancestors(@, 10)"
jj --no-pager log -r "descendants(@, 5)"
```
Optional revset queries when user asks for filtering:
```
# Author filter
jj --no-pager log -r "author('name@example.com') & ancestors(@, 20)"
# Files touched
jj --no-pager log -r "file('src/**') & ancestors(@, 30)"
```
Bookmark/WIP context to include in the lifeguard prompt (if applicable):
- Current bookmark name
- Whether parent description starts with "WIP:" and intended final message

Prompt template example (JJ):
```
Please load git claude skill.
Review JJ working copy and recent commits. Run the listed jj commands (modify as needed) to inspect changes; focus on correctness, style, and potential refactors. Repository uses JJ atop git.
Commands to run:
1. jj --no-pager status
2. jj --no-pager diff
3. jj --no-pager log -n 20 --no-graph
4. jj --no-pager diff -r @-..@
If needed: jj --no-pager show <rev>, jj --no-pager log -r "ancestors(@, 10)".
Bookmark: <bookmark-name>
Parent commit description: <parent-desc>
Relevant references (if needed): ~/.claude/skills/git-jj/references/jj_revset.md
```
Git prompt template (large diff scenario):
```
Please load git claude skill.
Review pending changes. Fetch diffs yourself; do NOT rely on inline diff copy. Focus on correctness, style, and commit structuring.
Commands to run:
1. git status
2. git diff
3. git log --oneline -n 20
```
When focusing on a subset of files, pass a short list of paths (not full diff). Lifeguard will retrieve their diffs directly.

Summary:
- Git: small diff inline OK; large diff let lifeguard fetch; always include skill loading phrase.
- JJ: pass command plan + context, not full diff; include skill loading phrase or attach needed reference paths.

### 3. Stage Changes
- **JJ**: Auto-tracks all changes (no staging needed)
- **Git**: Standard `git add` workflow

### 4. Commit Changes
- **CRITICAL**: NEVER commit without explicit user confirmation
- Before committing: Show summary and ask user to confirm
- **JJ**: Always use `-m` flag (bare `jj commit` opens editor, blocks agent). See `~/.claude/skills/git-jj/references/jj_workflows.md` for WIP pattern.
- After JJ commit: verify with `jj --no-pager log -n 4 --no-graph`

### 5. Push to Remote
- **CRITICAL**: NEVER push without explicit user confirmation
- NEVER use `--force` unless explicitly requested

### 6. Other Operations
- History, branches/bookmarks, worktrees: See reference files

## Key JJ vs Git Differences

- **JJ colocated**: When `.jj` + `.git` coexist, prefer jj commands
- **No staging in JJ**: All changes auto-tracked
- **JJ conflicts**: First-class objects (can commit conflicts)
- See `git_workflows.md` for full mapping table

## Example: Commit Workflow

1. Run `scripts/repo_check.sh` → Determine VCS type
2. Show current status/diff
3. **JJ**: Check for WIP commits (see `jj_workflows.md` WIP pattern)
4. **ASK USER** to confirm commit message
5. Execute commit only after confirmation
6. Verify with log output

## Safety Guidelines

1. **NEVER commit or push without explicit user confirmation**
2. **NEVER use force push** unless user explicitly requests it
3. **Verify branch/bookmark** before pushing (avoid main/master/staging)
4. **Pre-commit**: Show summary, suggest message, wait for approval
5. **Pre-push**: Show commits ahead of remote, verify target

## Integration Notes

- Favor `jj` when `.jj` folder exists
- Use `TodoWrite` for multi-step VCS workflows
- Read reference files only when command syntax is uncertain
