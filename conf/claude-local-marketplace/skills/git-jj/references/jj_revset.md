# JJ Revset Language Reference

Source: https://docs.jj-vcs.dev/latest/revsets/

Revsets select sets of revisions for inspection, history manipulation, and automation.

## Atoms

| Atom | Meaning |
|------|---------|
| `@` | Working-copy commit |
| `<commit-id>` | Specific commit (short/full hex) |
| `<change-id>` | Latest visible commit for change |
| `<bookmark>` | Bookmark target |
| `<bookmark>@<remote>` | Remote bookmark snapshot |
| `root()` | Virtual root |
| `trunk()` | Main branch |

## Operators

| Syntax | Meaning |
|--------|---------|
| `X::` | Ancestors of X (inclusive) |
| `::X` | Descendants of X (inclusive) |
| `A..B` | Reachable from B but not A |
| `A \| B` | Union |
| `A & B` | Intersection |
| `A - B` | Difference |

## Functions

| Function | Purpose |
|----------|---------|
| `all()` | All commits (visible + hidden) |
| `visible()` | Non-abandoned commits |
| `ancestors(X)` / `descendants(X)` | Ancestry traversal |
| `parents(X)` / `children(X)` | Direct relatives |
| `heads(X)` | Commits with no descendants in X |
| `author("name")` | By author substring |
| `description("regex")` | By description regex |
| `file("path")` | Commits affecting path |
| `present(X)` | Filter to visible form |

## Common Patterns

```bash
# Work since branching from main
main..@

# Commits affecting file
descendants(main) & file("src/lib.rs")

# Ahead of remote (push candidates)
feature - feature@origin

# Behind remote (need to pull)
feature@origin - feature

# Find WIP commits
description("WIP") & ::@

# Filter by author
author("alice") & main..@

# Divergent heads (conflicts)
heads(<change-id>)

# Hidden/abandoned commits
all() - visible()
```

## File Filtering

```bash
file("src/")                              # Commits under src/
file("src/") - file("src/test/")          # Exclude test dir
descendants(main) & file("*.rs")          # Rust files since main
```

## Pitfalls

| Issue | Fix |
|-------|-----|
| `A..B` direction confusion | B's ancestors minus A's ancestors |
| Using `all()` unnecessarily | Use `visible()` for normal queries |
| Hidden commits not showing | Use `all()` or `present()` |
| Shell expansion | Quote paths and regex |
