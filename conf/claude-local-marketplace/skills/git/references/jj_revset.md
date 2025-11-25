# JJ Revset Language Reference (Condensed)

Source summarized from: https://docs.jj-vcs.dev/latest/revsets/

## 1. Purpose
Revsets are functional expressions that select sets of revisions (commits) for inspection, scripting, history manipulation, and advanced workflows (rebasing, filtering, merging). They are composable, deterministic, and can represent complex topology queries compactly.

## 2. Core Concepts
- A revset expression evaluates to a SET of revisions.
- Many operations are closed over sets (union, intersection, difference).
- Change IDs vs Commit IDs: Multiple commits (rewrites) can share a change ID; revsets often operate at commit level but can be constrained by change identity.
- Visible vs Hidden: Some commits may be hidden (abandoned or rewritten). Use `all()` to include hidden; default queries usually return visible commits.

## 3. Basic Atoms
| Atom | Meaning |
|------|---------|
| `@` | Working-copy commit |
| `<commit-id>` | Specific commit (short or full hex) |
| `<change-id>` | Resolved to latest visible commit in that change (k-z alphabet) |
| `<bookmark>` | Target commit of bookmark |
| `<bookmark>@<remote>` | Remote bookmark snapshot |
| `root()` | Virtual root commit |
| `empty()` | Empty set |
| `none()` | Alias for empty set (if available) |

## 4. Set Operations
| Operator | Description | Example |
|----------|-------------|---------|
| `A | B` | UNION | `main | feature-x` |
| `A & B` | INTERSECTION | `(heads(main)) & (::feature-x)` |
| `A - B` | DIFFERENCE | `all() - visible()` |
| Parentheses | Grouping | `(main | feature) - stale()` |

## 5. Range & Topology Operators
| Syntax | Meaning | Notes |
|--------|---------|-------|
| `X::` | Ancestors of X (including X) | Equivalent to `ancestors(X)` |
| `::X` | Descendants of X (including X) | Equivalent to `descendants(X)` |
| `A..B` | Commits reachable from B but not from A | Directional range |
| `A..` | Commits reachable from working copy not from A | (context dependent) |
| `..B` | Commits reachable from B not from working copy | |
| `heads(X)` | Commits in X with no descendants in X | Useful for divergent changes |
| `roots(X)` | Commits in X with no ancestors in X | In some jj versions |

## 6. Common Functions (Selection Predicates)
| Function | Purpose |
|----------|---------|
| `all()` | All commits (visible + hidden) |
| `visible()` | Visible (non-abandoned) commits |
| `ancestors(X)` | Ancestors (inclusive) of X |
| `descendants(X)` | Descendants (inclusive) of X |
| `children(X)` | Direct children of X |
| `parents(X)` | Direct parents of X |
| `heads(X)` | Heads within set X |
| `connected(X)` | Commits connected to X |
| `none()` | Empty set |
| `author("name")` | Commits by author matching name substring |
| `committer("name")` | Commits by committer |
| `description("regex")` | Commits whose description matches regex |
| `changed("path")` | Commits that changed path (alias of `file("path")` patterns) |
| `file("path")` | Commits affecting file or directory |
| `present("rev")` | Filters out hidden rewrites, picks visible form |
| `dag_range(A, B)` | Commits on paths between A and B (exact semantics from docs) |
| `reachable(X)` | Commits reachable from X (often same as descendants) |

(Note: Availability may vary by jj version; verify with `jj log -r 'help()'` if implemented.)

## 7. Path/Fileset Integration
- `file("src/")` selects commits modifying anything under `src/`.
- Combine with topology: `descendants(main) & file("lib/util.rs")`.
- Use negation via set difference: `file("src/") - file("src/experimental/")`.

## 8. Divergence & Heads Use Cases
- Detect divergent rewrites of a change: `heads(change-id)` if multiple heads appear.
- List multiple heads under bookmark lineage: `heads(<bookmark>::)`.
- Resolve by merge/rebase then repoint bookmark.

## 9. Practical Patterns
| Goal | Revset |
|------|--------|
| Latest commit on bookmark | `<bookmark>` |
| All work since branching from main | `main..@` |
| Commits affecting file after tag X | `descendants(X) & file("path/to/file")` |
| Find orphaned heads | `heads(all()) - heads(visible())` (if hidden heads) |
| Show WIP chain | `@:: - ancestors(root())` (restrict if needed) |
| Affected commits by change ID | `<change-id>::` |
| Potential push targets (ahead of remote) | `<bookmark> - <bookmark>@origin` |
| Review range between two commits | `A..B` |
| All ancestors excluding merges (filter by description) | `ancestors(@) & description("^feat:")` |

## 10. Safety Uses
- Pre-push diff range: `<bookmark>@origin.. <bookmark>` ensures reviewing only new commits.
- Detect hidden rewrites: `all() - visible()` lists abandoned/hidden commits.
- Inspect divergence before cleanup: `heads(descendants(root()))`.

## 11. Filtering by Metadata
- Author: `author("alice") & descendants(main)`.
- Description regex: `description("WIP:") & ::@` to find lingering WIP descendants.
- Time-based (if supported via templates/external filtering): Use external grep on `jj log --template` output.

## 12. Combining Revsets Strategically
- Narrow then expand: `(file("src/") & descendants(main)) | <bookmark>` adds current head.
- Exclude noise: `descendants(main) - description("^chore:")`.
- Target resolution of conflicts: `heads(all()) & description("CONFLICT")` (if conflict markers in descriptions).

## 13. Bookmark & Remote Interaction
- Ahead-of-remote detection: `<bookmark> - <bookmark>@origin`.
- Remote-only commits not yet integrated: `<bookmark>@origin - <bookmark>`.
- Multi-remote assessment: `<bookmark>@origin | <bookmark>@upstream` then diff sets.

## 14. Performance Considerations
- Keep expressions simple for large repos (prefer explicit narrowing like `descendants(main)` over `all()`).
- Avoid broad unions over many bookmarks; consider iterating.
- Cache frequently used revsets via scripts (outside language itself).

## 15. Recommended Workflow Integration
1. Pre-review: `jj log -r '<bookmark>@origin.. <bookmark>'`.
2. Feature isolation: `jj log -r 'main..feature-x'`.
3. Impact analysis: `jj log -r 'descendants(feature-x) & file("src/critical/")'`.
4. Cleanup detection: `jj log -r 'heads(main::)'` find stray heads.

## 16. Common Pitfalls
| Pitfall | Mitigation |
|---------|-----------|
| Using `all()` unnecessarily | Use `visible()` unless inspecting hidden rewrites |
| Confusing `A..B` direction | Remember: range is commits reachable from B not from A |
| Overbroad file match | Use precise path or combine with narrower topology |
| Hidden commit not showing | Add `present()` or use `all()` directly |

## 17. Cheat Sheet Summary
```
Ancestors: X::
Descendants: ::X
Range: A..B
Union: A | B
Intersect: A & B
Difference: A - B
Heads: heads(X)
File filter: file("path")
Remote delta: <bm>@origin.. <bm>
Ahead local: <bm> - <bm>@origin
```

## 18. Usage Tips
- Always quote complex regex/paths if shell may expand.
- Use parentheses for clarity when mixing operators.
- Start simple: verify `jj log -r '<revset>'` returns expected subset.
- Integrate revsets into scripts for automation (diff checking, pre-push review).

## 19. Extension & Discovery
- Use `jj log -r 'help()'` (if available) or consult CLI reference for full function list.
- Explore internal functions for change/dag analysis in advanced scenarios.

---
**Remember**: Revsets are declarative. Shape your query around the minimal commit set you need, then enrich with metadata filters (author, description, file).
