# JJ Bookmarks Reference

Source: https://docs.jj-vcs.dev/latest/bookmarks/

## Core Concepts

- **Named pointer** to a revision - similar to Git branch but NO "current branch" concept
- **Auto-moves** when target is rewritten (`jj rebase`, `jj squash`, `jj describe`)
- **Auto-deletes** when commit is abandoned
- Usable anywhere a revision is expected: `jj new main`, `jj rebase -r feature -d main`
- In colocated repos, bookmarks map directly to Git branches

## Commands

| Action | Command |
|--------|---------|
| List local | `jj bookmark list` |
| List all (local + remote) | `jj bookmark list --all` |
| Create at @ | `jj bookmark create <name>` |
| Point to revision | `jj bookmark set <name> -r <rev>` |
| Delete | `jj bookmark delete <name>` |
| Rename | `jj bookmark rename <old> <new>` |
| Track remote | `jj bookmark track <name>@<remote>` |
| Untrack remote | `jj bookmark untrack <name>@<remote>` |
| Push single | `jj git push -b <name>` |
| Push all | `jj git push --all` |

Alias: `jj b` for `jj bookmark` (e.g., `jj b c` for create, `jj b d` for delete)

## Remote & Tracking

- Address remote: `<bookmark>@<remote>` (e.g., `main@origin`)
- Can track same-name bookmarks on multiple remotes
- Auto-tracked on: clone (default remote), first push of local bookmark
- Enable auto-track fetched: `git.auto-local-bookmark = true`

## Status Indicators

| Suffix | Meaning |
|--------|---------|
| `*` | Local differs from remote (needs push) |
| `??` | Conflicted (multiple targets) |
| `@<remote>` | Remote snapshot reference |

## Conflict Resolution

When bookmark becomes conflicted (divergent updates):
```bash
jj log -r 'all:<bookmark>'              # Inspect divergent commits
jj new 'all:<bookmark>'                 # Merge path: create merge commit
jj rebase -r <sideA> -d <sideB>         # Rebase path
jj bookmark set <name> -r <resolved>    # Finalize
```

## Safe Push Pattern

1. `jj git fetch` - sync remote state
2. `jj status` - check for conflicts (look for `??` markers)
3. `jj git push -b <name>` - push single bookmark

Push safety checks (force-with-lease equivalent):
- Remote position matches last known
- Local bookmark not conflicted
- Remote bookmark tracked (or use `--allow-new`)

## Revset with Bookmarks

```bash
jj new <bookmark>           # New commit on top
<bookmark>::                # Ancestors
::<bookmark>                # Descendants
heads(all:<bookmark>)       # All heads involving bookmark
```

## Git Comparison

| Git | JJ |
|-----|-----|
| Branch HEAD moves on commit | Bookmark only moves on rewrite |
| Single upstream per branch | Can track multiple remotes |
| Force push risk | Built-in force-with-lease protection |
