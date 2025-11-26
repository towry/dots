# Jujutsu (jj) Workflows Guide

**Version**: jj 0.9+

## Core Concepts

**Key differences from Git:**
- **Auto-snapshotting**: Most commands automatically commit working-copy changes
- **No staging area**: All tracked files are automatically included
- **`@` symbol**: Always represents current working-copy commit
- **Immutable history**: Operations create new commits; old commits remain accessible

## Quick Reference

### Status & Inspection
```bash
jj status                          # Snapshot and show status
jj diff --git                      # Working copy changes
jj diff --git -r <rev>             # Changes in specific revision
jj log -n 10                       # History (graph by default)
jj show <rev>                      # Commit details
```

### Creating & Modifying Commits
```bash
jj describe -m "message"           # Update current commit description
jj describe -r <rev> -m "msg"      # Update specific revision
jj commit -m "message"             # Create new commit, move @ forward
jj new -m "message"                # Create empty checkpoint commit
jj squash                          # Fold @ into parent (amend-like)
jj squash -f <src> -t <dest>       # Move changes between commits
jj abandon <rev>                   # Remove commit from history
jj duplicate <rev>                 # Cherry-pick equivalent
jj rebase -r <rev> -d <dest>       # Rebase revision
jj edit <rev>                      # Edit specific revision directly
```

### File Operations
```bash
jj restore <file>                  # Restore from parent
jj restore --from <rev> <file>     # Restore from specific revision
jj file track <path>               # Start tracking
jj file untrack <path>             # Stop tracking
```

### Bookmarks (Branches)
```bash
jj bookmark list                   # List all
jj bookmark create <name>          # Create at @
jj bookmark set <name> -r <rev>    # Point to revision
jj bookmark delete <name>          # Delete
jj bookmark track <name>@<remote>  # Set up tracking
```

### Remotes
```bash
jj git fetch                       # Fetch all
jj git fetch --remote <name>       # Fetch specific
jj git push -b <bookmark>          # Push bookmark
jj git push --all                  # Push all bookmarks
```

### Workspaces
```bash
jj workspace add <path>            # Create (like git worktree)
jj workspace list                  # List all
jj workspace forget <name>         # Remove
```

## WIP Commit Pattern

```bash
# Start work
jj describe -m "WIP: feature"

# Continue working (auto-snapshots on jj commands)

# Finalize (if @ is the WIP commit)
jj commit -m "feat: completed"
# use describe with `-r` if wip commits is in parents.

# Or squash into parent
jj squash
```

**Before committing**, check state:
```bash
jj --no-pager status
jj --no-pager log -r '@-'          # Check parent
```

## Conflict Resolution

JJ allows committing conflicts and resolving them later.

### Recommended: Resolve in New Commit
```bash
jj new <conflicted-commit>         # Create child
# ... edit files to resolve ...
jj diff                            # Review resolutions
jj squash                          # Merge back into parent
```

### Alternative: Direct Edit
```bash
jj edit <conflicted-commit>
# ... resolve conflicts ...
jj describe -m "resolved conflicts"
```

### External Tool
```bash
jj resolve                         # Opens merge tool (2-sided conflicts only)
```

## Git Command Mappings

| Git | jj |
|-----|-----|
| `git status` | `jj status` |
| `git diff` | `jj diff --git` |
| `git add .` | (automatic) |
| `git commit -m` | `jj commit -m` |
| `git commit --amend` | `jj squash` or `jj describe` |
| `git log` | `jj log` |
| `git branch` | `jj bookmark list` |
| `git checkout <branch>` | `jj edit <bookmark>` |
| `git merge <branch>` | `jj new <rev1> <rev2>` |
| `git rebase` | `jj rebase -r <rev> -d <dest>` |
| `git cherry-pick` | `jj duplicate <rev>` |
| `git stash` | `jj new` (checkpoint) |
| `git worktree add` | `jj workspace add` |

## Revision Syntax

- `@` - Working copy
- `@-` - Parent of working copy
- `<bookmark>` - Bookmark target
- `<rev>::` - Ancestors
- `::<rev>` - Descendants
- `<rev1>..<rev2>` - Range
- `trunk()` - Main branch
- `file('<path>')` - Revisions modifying file

## Fileset Language

### Patterns
| Pattern | Description |
|---------|-------------|
| `"path"` | CWD-relative prefix (recursive) |
| `file:"path"` | Exact file match |
| `glob:"*.rs"` | CWD-relative glob |
| `root:"path"` | Workspace-relative prefix |
| `root-glob:"**/*.rs"` | Workspace-relative glob |

### Operators
| Op | Meaning | Example |
|----|---------|---------|
| `~x` | NOT | `~Cargo.lock` |
| `x & y` | AND | `src & glob:"*.rs"` |
| `x ~ y` | MINUS | `src ~ glob:"*test*"` |
| `x \| y` | OR | `src \| tests` |

### Examples
```bash
jj diff '~Cargo.lock'                        # Exclude file
jj diff 'glob:"**/*.md"'                     # Only markdown
jj log -r 'trunk()..@ & file("src/core")'    # Commits touching path
jj diff --git -f "trunk()" -t "@"            # Diff vs trunk
```

## Important Notes

1. **Always use `-m` flag** in non-interactive contexts (scripts, LLM agents)
2. **Check status before critical ops**: `jj --no-pager status`
3. **Conflicts are first-class**: Can be committed, shared, resolved incrementally
4. **Operations are recoverable**: `jj op log` shows history
