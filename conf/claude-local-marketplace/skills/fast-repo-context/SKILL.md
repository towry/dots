---
name: fast-repo-context
description: "Semantic code search using sgrep. Use when: exploring code, search code snippets, finding implementations by intent, understanding how features work. Triggers(semantic or similiar meaning): [fast context], [search code], [find where], [how does X work], [understand codebase], [research codebase], [find X], [locate X], [code search], [grep code], [where is], [let me search]."
---

# Fast Repo Context

Semantic grep (`sgrep script`) for code search with natural language queries. Note: it only give code snippets/what/where, not how or code explanations, so your query need to be focus on what/where.

## Tool

```bash
bash ~/.claude/skills/fast-repo-context/scripts/sgrep.sh --json "<natural language query>"
```

**Safety:** Script checks if current directory is a git repo before running to prevent accidental indexing of large/wrong directories.

**Options:**
- `--json` - Structured JSON output (recommended for agents)
- `-n, --limit <N>` - Max results (default: 10)
- `-c, --context` - Show extra context around matches
- `--glob <GLOB>` - Restrict to file patterns (repeatable)
- `--filters <FILTERS>` - Filter by metadata (e.g., `lang=rust`)

## When to Use

- Exploring unfamiliar codebases
- Finding code by intent/behavior (not just keywords)
- Understanding how features are implemented
- Locating related code across files
- Find something in another project/repo on disk

## Workflow

1. **Use sgrep script** for semantic search
2. **Read specific files** from results for details
3. **(Optional)** Query `kg` from our knowledge graph for additional context

## Examples

### Find authentication logic
```bash
~/.claude/skills/fast-repo-context/scripts/sgrep.sh --json "user login and session management"
```

### Find in another project/repo

Use bash `exa --tree -D -L 2 ~/workspace` to get all projects in ~/workspace.

```
cd another-dir-abs-path && ~/.claude/skills/fast-repo-context/scripts/sgrep.sh --json "file upload handling that use api foo/bar"
```

### Find error handling patterns
```bash
~/.claude/skills/fast-repo-context/scripts/sgrep.sh --json "how errors are caught and reported to users"
```

### Find API endpoints
```bash
~/.claude/skills/fast-repo-context/scripts/sgrep.sh --json "REST endpoints for user profile operations"
```

### Find database queries
```bash
~/.claude/skills/fast-repo-context/scripts/sgrep.sh --json "queries that fetch user data with pagination"
```

### Find React hooks usage
```bash
~/.claude/skills/fast-repo-context/scripts/sgrep.sh --json "custom hooks for form validation"
```

### With filters
```bash
~/.claude/skills/fast-repo-context/scripts/sgrep.sh --json --glob "*.ts" --limit 5 "error handling middleware"
```

## Tips

- **Be descriptive**: "function that validates email format" > "email validation"
- **Describe intent**: "code that prevents duplicate submissions" > "debounce"
- **Ask questions**: "where is the shopping cart total calculated?"

