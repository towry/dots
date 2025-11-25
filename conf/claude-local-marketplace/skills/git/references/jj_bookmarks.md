# JJ Bookmarks Reference (Condensed)

Source summarized from official docs: https://docs.jj-vcs.dev/latest/bookmarks/

## 1. Concept & Core Behaviors
- A bookmark is a named pointer to a revision (commit). Similar to a Git branch but does NOT become "current"; there is no active bookmark concept.
- Bookmarks automatically move when their target revision is rewritten (e.g. via `jj rebase`, `jj squash`, `jj describe`, conflict resolution).
- You can pass bookmark names anywhere a revision is expected: `jj new main`, `jj rebase -r feature -d main`, etc.
- Deleting or abandoning a commit deletes associated bookmarks.

## 2. Mapping to Git Branches
- In colocated repos (`.jj` and `.git` siblings), bookmarks map directly to Git branches.
- `jj git push --bookmark foo` updates remote branch `foo`.
- Remote Git branches imported become bookmarks (automatic in colocated setup or via explicit import/fetch).

## 3. Remote & Tracking Model
- Remote bookmark snapshot recorded on every `jj git fetch` / `jj git push`.
- Address remote bookmark position with `<bookmark>@<remote>` (e.g. `main@origin`).
- A bookmark can track multiple remotes simultaneously if same name exists.
- Tracking relationship ensures local bookmark updates incorporate remote movement (merge or conflict).

### Tracking Operations
- Track: `jj bookmark track <name>@<remote>`
- Untrack: `jj bookmark untrack <name>@<remote>`
- List tracked: `jj bookmark list --tracked` or `jj b l -t`
- Show all local + remote: `jj bookmark list --all`

### Automatic Tracking
- On clone: default remote bookmark (e.g. `main@origin`) auto-tracked.
- On first push of a local bookmark: remote bookmark becomes tracked.
- Enable global auto-tracking of newly fetched bookmarks: set config `git.auto-local-bookmark = true`.

## 4. Bookmark Updates & Safety
- Auto-move on rewrite; auto-delete when commit abandoned.
- Push safety checks (before remote update):
  1. Remote actual position matches last known (like force-with-lease semantics).
  2. Local bookmark is not conflicted.
  3. Remote bookmark is tracked (unless creating new with `--allow-new`).
- If mismatch/conflict: must `jj git fetch` then resolve before pushing again.

### Safe Push Pattern
1. Inspect local diff/log.
2. Ensure no bookmark conflicts (`jj status`, look for suffix markers).
3. Confirm remote alignment if uncertain: `jj git fetch --remote origin`.
4. Push single bookmark: `jj git push --bookmark feature-x`.
5. Push all (explicit user confirmation required): `jj git push --all`.
6. Avoid force operations; if user explicitly requests: explain risk first.

## 5. Conflicts
- A bookmark becomes conflicted when divergent updates occur (local + remote or multiple rewrites).
- Display indicators:
  - `jj log` shows bookmark name suffixed with `??` on potential targets.
  - `jj status` reports conflicted bookmarks and mitigation hints.
  - Remote divergence (remote target differs) may show asterisk `*` (e.g. `main*`) meaning local ahead/needs push.
- Resolve local bookmark conflict: merge or rebase divergent commits, then point bookmark explicitly: `jj bookmark set main -r <resolved_rev>` or `jj bookmark move main -r <resolved_rev>`.
- Resolve remote bookmark conflict: `jj git fetch` then apply resolution locally.

## 6. Common Commands Cheat Sheet
| Action | Command |
|--------|---------|
| List local bookmarks | `jj bookmark list` |
| List all (local + remote) | `jj bookmark list --all` |
| Create bookmark at @ | `jj bookmark create <name>` |
| Point bookmark to rev | `jj bookmark set <name> -r <rev>` |
| Delete bookmark | `jj bookmark delete <name>` |
| Rename bookmark | `jj bookmark rename <old> <new>` |
| Track remote bookmark | `jj bookmark track <name>@<remote>` |
| Untrack remote bookmark | `jj bookmark untrack <name>@<remote>` |
| List tracked bookmarks | `jj bookmark list --tracked` |
| Push single bookmark | `jj git push --bookmark <name>` or `jj git push -b <name>` |
| Push all bookmarks | `jj git push --all` |
| Show remote state | `jj show <name>@<remote>` |

Short aliases (where available): `jj b` for `jj bookmark`; subcommands often shorten (e.g. `jj b c` for create, `jj b d` for delete) depending on installed alias configuration.

## 7. Recommended Workflow for Feature Bookmark
1. Start feature: `jj bookmark create feat-add-thing` (or after commit creation).
2. Work; auto-snapshots update `@` but bookmark stays pointed to last stable commit until rewrite.
3. Finalize change: `jj commit -m "feat: add thing"` then adjust bookmark if needed: `jj bookmark set feat-add-thing -r @`.
4. Fetch remote updates: `jj git fetch --remote origin`.
5. Confirm no conflicts: `jj status`.
6. Push bookmark: `jj git push -b feat-add-thing`.
7. If remote divergence arises: resolve by merge/rebase before pushing again.

## 8. Conflict Resolution Strategy
- Inspect divergent commits: `jj log -r 'all:<bookmark>'`.
- Merge path: `jj new 'all:<bookmark>'` then `jj squash` or rebase.
- Rebase path: `jj rebase -r <sideA> -d <sideB>` then repoint bookmark.
- Finalize: `jj bookmark set <name> -r <resolved_rev>`.

## 9. Diagnostics & Indicators
| Suffix | Meaning |
|--------|---------|
| `*` | Local bookmark differs from remote version (push likely) |
| `??` | Conflicted bookmark (multiple potential targets) |
| `@<remote>` | Remote snapshot reference |

Use `jj bookmark list --all` + `jj log` together for situational awareness.

## 10. Safety Notes
- Always fetch (`jj git fetch`) before push in multi-collaborator contexts.
- Never push conflicted bookmark; resolve first.
- Avoid `--force` unless explicitly approved and documented.
- Confirm with user before pushing deletions or mass updates.

## 11. Comparison with Git
| Git | JJ Bookmark Behavior |
|-----|----------------------|
| Branch HEAD moves on commit | Bookmark does NOT move automatically; rewrites move it |
| Upstream tracking single remote | Bookmark can track same-name bookmarks on multiple remotes |
| Force push risk | JJ safety checks emulate force-with-lease protections |
| Branch creation `git branch` | Bookmark creation `jj bookmark create` |

## 12. Quick Revset Usage with Bookmarks
- New commit on top: `jj new <bookmark>`
- Ancestors: `<bookmark>::`
- Descendants: `::<bookmark>`
- All heads involving bookmark: `heads(all:<bookmark>)`

## 13. Bookmark Maintenance
- Prune obsolete bookmarks: list all, delete those pointing to merged/abandoned commits.
- Audit remote drift: periodic `jj bookmark list --all` + `jj git fetch`.
- For large repos: script a report diffing local vs remote positions.

---
**Remember**: Bookmarks are lightweight pointers that follow rewrites; manage them declaratively (set/move) rather than implicitly through commits.
