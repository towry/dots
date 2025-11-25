# Jujutsu (jj) Workflows Guide

**Version note**: Commands tested with jj 0.9+. Some commands may differ in older versions.

## Understanding JJ's Working Copy Model

**Critical concept**: Jujutsu automatically creates commits from working-copy contents when they have changed.

Key differences from Git:
- **Auto-snapshotting**: Most `jj` commands automatically commit working-copy changes if modified
- **Working-copy commit**: The resulting revision replaces the previous working-copy revision
- **Auto-tracking**: Added files are implicitly tracked by default (no `git add` equivalent needed)
- **`@` symbol**: Always represents the current working-copy commit

### How JJ Handles Changes
1. When you modify files, jj doesn't commit them immediately
2. When you run most jj commands (like `jj st`, `jj log`, etc.), jj automatically snapshots the working copy
3. The snapshot creates/updates the working-copy commit (represented by `@`)
4. Running `jj commit` or `jj describe` works with this automatically-snapshotted state

### Working Copy States
1. **Working copy with uncommitted changes**: Files modified since last snapshot
2. **Clean working copy**: No modifications since last snapshot (common state)
3. **Empty working-copy commit**: The `@` commit has no changes (normal after `jj commit`)

**Important**: Unlike Git, there is no staging area. All tracked files are automatically included in snapshots.

## WIP (Work-In-Progress) Commit Pattern

Many jj users create "WIP:" commits for incremental work:

### Creating WIP commits
```bash
# Describe your current work
jj describe -m "WIP: feature description"
# ... continue making changes ...
# jj auto-snapshots changes into the working-copy commit

# Option 1: Create new commit on top (finalizing WIP)
jj commit -m "feat: completed feature"  # Creates new child, moves @ forward

# Option 2: Squash working-copy changes into parent
jj squash  # Moves changes from @ into parent commit
```

### When to use WIP pattern
- Experimental changes you may abandon
- Incremental progress checkpoints
- Sharing work-in-progress with team (push WIP bookmark)

### Handling WIP commits
**Before running `jj commit`**, check the current state:
```bash
jj --no-pager status
jj --no-pager log -r '@-'  # Check parent commit description
```

Decision tree:
- **Parent commit has "WIP:" description**: Ask user:
  - Squash into WIP: `jj squash` (merge @ into parent)
  - Create new commit: `jj commit -m "message"`
  - Edit WIP description: `jj describe -r '@-' -m "new message"`
- **Working copy has changes, no description**: Use `jj describe -m "message"` to add description
- **Clean working copy**: Ready for new work

## Repository Status
- View status: `jj --no-pager status` or `jj st` (auto-snapshots working copy)
- Show working copy changes: `jj --no-pager diff --git`
- Show changes in specific revision: `jj --no-pager diff --git -r <revision>`
- Show summary statistics: `jj --no-pager diff --stat`
- Check without pager: `jj --no-pager status` (for scripting)

## Working with Changes
- Describe current changes: `jj describe -m "message"` (updates working copy commit)
- Create new commit from changes: `jj commit -m "message"` (creates child commit)
- Restore file to last commit: `jj restore <file>`
- Discard all changes: `jj restore --from @` (restore to current commit)

**Note**: jj automatically tracks all changes in the working copy. No explicit "staging" required.

## Commits
- Create commit with message: `jj commit -m "message"` or `jj describe -m "message"`
- **IMPORTANT**: `jj commit` without `-m` opens an interactive editor - avoid in non-interactive contexts (LLM agents, scripts)
- Show commit details: `jj show` (current) or `jj show <revision>`
- Edit commit description: `jj describe -r <revision> -m "new message"`
- Amend commit: `jj squash` (squash working changes into parent)

## History & Navigation
- Show log: `jj log`
- Show log with graph: `jj --no-pager log --no-graph` (graph is default)
- Limit log entries: `jj --no-pager log -n 10 --no-graph`
- Show log for specific file: `jj --no-pager log <file>` or `jj --no-pager log -r "file('<path>')"`
- Show ancestors of revision: `jj --no-pager log -r '<revision>::'`

## Branches (Bookmarks)
- List bookmarks: `jj bookmark list` or `jj bookmark`
- Create bookmark at current commit: `jj bookmark create <name>`
- Create bookmark at specific revision: `jj bookmark set <name> -r <revision>`
- Move to bookmark: `jj edit <bookmark>` or `jj new <bookmark>`
- Delete bookmark: `jj bookmark delete <name>`
- Rename bookmark: `jj bookmark rename <old> <new>`

**Terminology**: jj uses "bookmarks" for what git calls "branches". They're lightweight pointers to commits.

## Working with Remotes
- Fetch from remote: `jj git fetch`
- Fetch specific remote: `jj git fetch --remote <remote-name>`
- Push bookmark: `jj git push --bookmark <name>` or `jj git push -b <name>`
- Push current bookmark: `jj git push` (if tracking is set)
- Push all bookmarks: `jj git push --all`
- Set up tracking: `jj bookmark track <name>@<remote>`

## Working with Workspaces
- Create new workspace: `jj workspace add <path>`
- List workspaces: `jj workspace list`
- Remove workspace: `jj workspace forget <workspace-name>`
- Update workspace name: `jj workspace rename <old> <new>`

**Note**: Workspaces are jj's equivalent to git worktrees, allowing multiple working copies of the same repo.

## Conflict Resolution

### How JJ Handles Conflicts
- **Conflict markers in files**: JJ writes conflict markers to conflicted files in the working copy
- **Persistent tracking**: JJ tracks the (typically 3) parts involved in each conflict
- **Auto-parsing**: When scanning the working copy, JJ automatically parses conflict markers and recreates conflict state
- **Partial resolution**: You can resolve part of a conflict or update individual conflict parts incrementally

### Viewing Conflicts
- Show conflicted files: `jj status`
- View conflict markers: Open conflicted files directly (markers are standard text)
- Inspect conflict structure: JJ maintains the 3-way merge state (base, side1, side2)

### Resolution Strategies

#### Strategy 1: Resolve in New Working-Copy Commit (Recommended)
```bash
# Create working-copy commit on top of conflicted commit
jj new <conflicted-commit>

# Edit files to resolve conflicts (conflict markers appear in working copy)
# ... resolve conflicts in your editor ...

# Inspect your resolutions
jj --no-pager diff

# Move resolutions into the conflicted commit
jj squash
```
**Advantage**: Easy to review conflict resolutions with `jj --no-pager diff` before finalizing.

#### Strategy 2: Resolve Directly in Conflicted Commit
```bash
# Edit conflicted commit directly in working copy
jj edit <conflicted-commit>

# Resolve conflicts in files
# ... resolve conflicts ...

# Commit describes the resolution
jj describe -m "resolved conflicts"
```
**Disadvantage**: Harder to inspect conflict resolutions separately.

### Using External Merge Tools
- For 2-sided conflicts with a base: `jj resolve`
- Opens external merge tool configured for your system
- Only works for eligible two-sided conflicts

### Special Cases & Limitations
- **Directory/File/Symlink conflicts**: Limited support (see https://github.com/jj-vcs/jj/issues/19)
  - Use `jj restore <path>` to choose one side of the conflict
  - Cannot easily see where the involved parts came from
- **Abandoning conflicted commits**: `jj abandon <revision>` (discards commit entirely)

### Partial Resolution Pattern
```bash
# Resolve some conflicts, leave others
# Edit only the files you're ready to resolve

# JJ will maintain conflict state for unresolved files
jj status  # Shows remaining conflicts

# Continue resolving incrementally across multiple edits
```

**Unique feature**: Unlike git, jj allows you to commit conflicts and resolve them later. Conflicts are first-class objects that can be shared, branched, and resolved incrementally.

## Advanced Operations
- Create new empty commit: `jj new -m "message"`
- Move to specific revision: `jj edit <revision>`
- Duplicate commit: `jj duplicate <revision>` (similar to cherry-pick)
- Abandon commit: `jj abandon <revision>` (removes commit from history)
- Squash changes: `jj squash` (fold working copy into parent)
- Move changes between commits: `jj move --from <source> --to <dest>`

## Common Git to jj Command Mappings

| Git Command | jj Equivalent | Notes |
|-------------|---------------|-------|
| `git status` | `jj status` | Similar output |
| `git diff` | `jj --no-pager diff --git` | Shows working copy changes |
| `git diff --staged` | `jj diff` | No staging area in jj |
| `git add .` | (automatic) | jj tracks all changes automatically |
| `git commit -m "msg"` | `jj commit -m "msg"` or `jj describe -m "msg"` | describe updates current, commit creates new |
| `git commit --amend` | `jj describe` | Updates working copy commit |
| `git log` | `jj log` | Graph view by default |
| `git log --graph` | `jj log` | Always shows graph |
| `git branch` | `jj bookmark list` | |
| `git branch <name>` | `jj bookmark create <name>` | |
| `git checkout <branch>` | `jj edit <bookmark>` | |
| `git checkout -b <name>` | `jj bookmark create <name>` then `jj edit <name>` | |
| `git switch <branch>` | `jj edit <bookmark>` | |
| `git merge <branch>` | `jj new <rev1> <rev2>` (or `jj new <bookmark1> <bookmark2>`) | First listed revision becomes first parent of merge commit |
| `git rebase` | `jj rebase -r <revision> -d <destination>` | Non-destructive |
| `git cherry-pick` | `jj duplicate <revision>` | |
| `git push origin <branch>` | `jj git push -b <bookmark>` | |
| `git pull` | `jj git fetch` then `jj rebase` or manual merge via `jj new <rev1> <rev2>` | No auto-merge |
| `git fetch` | `jj git fetch` | |
| `git worktree add` | `jj workspace add` | |
| `git stash` | (not needed) | Use `jj new` to create checkpoint |

## Revision Syntax
- `@` - Working copy commit
- `<bookmark>` - Commit pointed to by bookmark
- `<revision>::` - Ancestors of revision
| `::<revision>` - Descendants of revision
- `<rev1>..<rev2>` - Range between revisions
- `file('<path>')` - Revisions that modify file

## Fileset Language (Path Filtering)

Filesets select sets of files for operations like `jj diff`, `jj file list`, `jj split`, etc. Filesets combine patterns, operators, and functions.

### File Patterns
| Pattern | Description | Example |
|---------|-------------|---------|
| `"path"` or `cwd:"path"` | CWD-relative path prefix (recursive) | `src/` matches all under `src/` |
| `file:"path"` | CWD-relative exact file match | `file:"README.md"` |
| `glob:"pattern"` | CWD-relative glob (non-recursive by default) | `glob:"*.rs"` |
| `glob-i:"pattern"` | Case-insensitive glob | `glob-i:"*.TXT"` |
| `root:"path"` | Workspace-relative path prefix | `root:"src/"` from repo root |
| `root-file:"path"` | Workspace-relative exact file | `root-file:"Cargo.toml"` |
| `root-glob:"pattern"` | Workspace-relative glob | `root-glob:"**/*.rs"` (recursive) |

**Note**: Quotes optional if no spaces/special chars. Shell quoting may still be needed.

### Operators
| Operator | Meaning | Example |
|----------|---------|---------|
| `~x` | NOT (everything except x) | `~Cargo.lock` |
| `x & y` | AND (both x and y) | `src & glob:"*.rs"` |
| `x ~ y` | MINUS (x but not y) | `src ~ glob:"*test*"` |
| `x \| y` | OR (either x or y) | `src \| tests` |

### Functions
- `all()` – Matches all files
- `none()` – Matches no files

### Common Usage Patterns
| Goal | Fileset |
|------|---------|
| All Rust files in src | `glob:"src/**/*.rs"` or `src & glob:"**/*.rs"` |
| Exclude lock files | `~Cargo.lock` or `~"*.lock"` |
| Only documentation | `glob:"docs/**/*.md"` |
| Split commit keeping only foo | `jj split '~foo'` (moves non-foo to new commit) |
| Diff excluding vendored | `jj diff '~vendor'` |
| List modified test files | `jj file list 'glob:"**/*test*.rs"'` |
| Diff changes between <rev:@> and main/master(trunk) branch | `jj diff --git -f "trunk()" -t "@"` |

### Practical Examples
```bash
# Show diff excluding Cargo.lock
jj diff '~Cargo.lock'

# List files in src excluding Rust sources
jj file list 'src ~ glob:"**/*.rs"'

# Diff only changes to markdown files
jj diff 'glob:"**/*.md"'

# Split revision keeping only specific file
jj split 'file:"main.rs"'

# Show status for all Python files
jj status 'glob:"**/*.py"'
```

### Integration with Revsets
Combine filesets with revsets for powerful queries:
```bash
# Commits in range affecting specific files
jj log -r 'trunk()..@ & file("src/core")'

# Show diff for feature branch touching tests only
jj diff -r 'feature-x' 'glob:"**/test_*.rs"'
```

**Tip**: Use `root-glob:` for patterns relative to repo root regardless of CWD; use `cwd-glob:` (default) for current-directory-relative patterns.

## Tips
1. **No staging area**: All changes are automatically tracked
2. **Immutable history**: Operations create new commits; old commits remain accessible
3. **Conflicts as objects**: Can commit and share conflicted states
4. **Use `jj describe`** for quick commit message updates
5. **Use `jj new`** to create checkpoints before experimental changes
6. **Interactive commands**: Some jj commands open editors when run without arguments (e.g., `jj commit`, `jj describe`, `jj split`). Always use `-m` flag or other non-interactive options in scripting/automation contexts to avoid blocking.

## CLI Command Reference (Condensed)

Categorized quick-reference for frequently used jj CLI commands (supplements earlier workflow sections).

### Working Copy & Inspection
- `jj st` / `jj status` – Snapshot working copy; show summary
- `jj diff` – Show changes in working copy vs parent(s)
- `jj diff -r <rev>` – Show changes introduced by a specific revision
- `jj log [-n N]` – Show commit/change graph
- `jj show <rev>` – Show commit metadata and diff summary
- `jj op log` – Show operation log history
- `jj workspace update-stale` – Refresh stale working copy after external rewrite

### Change Creation & Modification
- `jj describe -m "msg"` – Update working-copy commit's description
- `jj commit -m "msg"` – Create new child commit moving `@` forward
- `jj new -m "msg"` – Create a new empty commit (checkpoint)
- `jj squash` – Move changes from working copy into parent (amend-like)
- `jj abandon <rev>` – Hide/abandon a commit (kept but hidden)
- `jj duplicate <rev>` – Duplicate commit (cherry-pick equivalent)
- `jj move --from <revA> --to <revB>` – Move change contents between commits
- `jj rebase -r <rev> -d <dest>` – Rebase a revision onto new destination
- `jj new <rev1> <rev2>` – Create merge commit combining revisions (first rev becomes first parent)

### File Tracking & Restoration
- `jj restore <path>` – Restore file(s) from parent into working copy
- `jj restore --from <rev> <path>` – Restore file(s) from specified revision
- `jj file track <path>` – Manually start tracking file if auto-track disabled
- `jj file untrack <path>` – Stop tracking (ensure ignored or removed from auto-track patterns)

### Bookmarks (Branch Analogs)
- `jj bookmark list` – List bookmarks
- `jj bookmark create <name>` – Create bookmark at current `@`
- `jj bookmark set <name> -r <rev>` – Point bookmark to specific revision
- `jj bookmark delete <name>` – Delete bookmark
- `jj bookmark rename <old> <new>` – Rename bookmark
- `jj bookmark track <name>@<remote>` – Create tracking relationship

### Workspaces (Git Worktree Analogs)
- `jj workspace list` – List workspaces
- `jj workspace add <path>` – Create additional workspace
- `jj workspace forget <name>` – Remove workspace registration
- `jj workspace root` – Show root path of current workspace

### Remotes & Git Interop
- `jj git fetch` – Fetch changes/bookmarks from remote(s)
- `jj git fetch --remote <name>` – Fetch from specific remote
- `jj git push` – Push current tracked bookmarks
- `jj git push --bookmark <name>` / `-b <name>` – Push single bookmark
- `jj git push --all` – Push all bookmarks

### Conflict Management
- `jj resolve` – Use external merge tool for eligible two-sided conflicts
- `jj status` – Lists conflicted files (with markers in working copy)
- `jj squash` – Integrate resolved conflicts into parent commit
- `jj edit <rev>` – Edit a conflicted commit directly (advanced)

### Safety & Hygiene Commands
- `jj op log` – Inspect operations sequence
- `jj op abandon <op>` – Abandon an operation (advanced)
- `jj workspace update-stale` – Repair stale working copy
- `jj git push --force` – Force update (AVOID unless explicit user instruction)

### Typical JJ Feature Flow (Example)
1. Ensure workspace clean: `jj --no-pager status`
2. Describe WIP: `jj describe -m "WIP: add feature"`
3. Iterate changes (auto-snapshot on commands like `jj st`)
4. Finalize: `jj commit -m "feat: add feature"`
5. Create bookmark: `jj bookmark create feature-x`
6. Push: `jj git push -b feature-x` (after user confirmation)

**Note**: Auto-snapshotting means many commands implicitly update the working-copy commit. Always re-run `jj --no-pager status` before critical operations (commit, squash, push) to confirm state.
