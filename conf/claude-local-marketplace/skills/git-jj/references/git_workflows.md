# Git Quick Reference

Standard git commands assumed known. This covers less common operations and JJ mapping.

## Less Common Commands

```bash
git add -p <file>              # Interactive hunk staging
git restore --staged <file>    # Unstage (preferred over reset)
git switch -c <name>           # Create+switch (preferred over checkout -b)
git reflog                     # Local HEAD history (recovery)
git worktree add ../<dir> <branch>  # Parallel working directory
git stash show -p stash@{0}    # Show stash diff
```

## Safety Reminders

- Confirm before: `reset --hard`, `branch -D`, `push --force`, `clean -fd`
- Recovery: `git reflog` + `git branch <name> <hash>`

## Git to JJ Mapping

| Git | JJ |
|-----|-----|
| branch | bookmark |
| stash | `jj new` (checkpoint) |
| worktree | workspace |
| checkout/switch | `jj edit` |
| commit --amend | `jj describe` or `jj squash` |
| rebase | `jj rebase` (non-destructive) |
| cherry-pick | `jj duplicate` |
| merge | `jj new <rev1> <rev2>` |