# JJ Templating Language (Advanced Usage Only)

Source summarized from: https://docs.jj-vcs.dev/latest/templates/
Purpose: Provide power features for complex automation, custom log/report generation, and structured output pipelines. Keep default usage simple; only adopt templates when plain `jj log` output is insufficient.

---
## 1. When To Use Templates (Advanced Scenarios)
Use a custom `--template` ONLY when you need:
- Machine-readable structured output (JSON‑like) for scripts.
- Color/semantic highlighting for large code reviews.
- Aggregating metadata across commits (authors per range, per‑file change stats).
- Conditional formatting based on commit attributes (e.g., emphasize WIP or conflicted heads).
- Building dashboards (pipe into fzf, jq, or TUI).

Avoid templates for casual history viewing; they add cognitive overhead.

---
## 2. Invocation Patterns
- Single commit formatting: `jj log -r @ --template '...'`
- Range export: `jj log -r 'trunk()..@' --template '...'`
- Quiet integration (no pager): add `--no-pager`.
- Feed into tools: `jj log --template '<tmpl>' | jq ...` (if emitting JSON).

---
## 3. Core Expression Elements
Templates are expression trees combining literals, fields, functions, pipes, conditionals.

### Common Commit Fields
| Field | Description |
|-------|-------------|
| `commit_id` | Full commit id (hex) |
| `change_id` | Change identity (k-z alphabet) |
| `description` | Full commit message |
| `subject` | First line of description |
| `author` / `author.email` / `author.name` | Author metadata |
| `committer` | Committer metadata |
| `timestamp` | Commit committer timestamp |
| `tags` | List of tags |
| `bookmarks` | List of bookmarks pointing here |
| `conflict` | Boolean; commit contains conflicts |
| `is_empty` | Boolean; commit has no file changes |
| `divergent` | Boolean; change id has multiple visible heads |
| `parents` | List of parent commits |
| `root` | Boolean; virtual root |

### Short/Formatting Helpers
Most fields have helper variants:
- `commit_id.short()`
- `change_id.short()`
- `author.email.lower()`
- `description.first_line()` (or subject)

### Lists & Iteration
- `bookmarks.join(", ")`
- `tags.len()` -> integer
- `parents.map(commit_id.short()).join(" ")`

---
## 4. Functions & Pipes (Selected Advanced)
| Function | Purpose | Example |
|----------|---------|---------|
| `format()` | Concatenate / format | `format("[", change_id.short(), "] ", subject)` |
| `indent(n)` | Indent multiline blocks | `description.indent(4)` |
| `lower() / upper()` | Case transforms | `author.name.upper()` |
| `short()` | Abbreviate IDs | `commit_id.short()` |
| `json()` | JSON escape/quote | `format('{"id": "', commit_id.short().json(), '"}')` |
| `pad(width)` | Pad string | `subject.pad(50)` |
| `truncate(n)` | Truncate string | `description.truncate(80)` |
| `if(cond, a, b)` | Inline conditional | `if(conflict, "⚠ CONFLICT", "")` |
| `contains(substr)` | Search within string | `subject.contains("WIP")` |
| `regex_match(r)` | Regex boolean | `description.regex_match("^feat:")` |
| `map(f)` | Transform list | `bookmarks.map(lower())` |
| `filter(f)` | Filter list | `bookmarks.filter(!contains("temp"))` |
| `len()` | Length of list | `parents.len()` |

Chaining example: `bookmarks.filter(!contains("WIP")).map(lower()).join(" ")`.

---
## 5. Conditional Highlighting Patterns
Colorization (pseudo; terminal may differ):
```
format(
  if(divergent, "\x1b[33mDIV\x1b[0m ", ""),
  if(conflict, "\x1b[31mCONFLICT\x1b[0m ", ""),
  change_id.short(), " ", subject
)
```
Add WIP emphasis:
```
format(
  if(subject.contains("WIP"), "[WIP] ", ""),
  change_id.short(), " ", subject
)
```

---
## 6. Structured (Pseudo‑JSON) Output
```
format(
  '{',
  '"change":"', change_id.short().json(), '",',
  '"commit":"', commit_id.short().json(), '",',
  '"author":"', author.email.json(), '",',
  '"bookmarks":[', bookmarks.map(json()).join(","), '],',
  '"conflict":', if(conflict, 'true','false'), ',',
  '"parents":[', parents.map(commit_id.short().json()).join(","), ']',
  '}'
)
```
Pipe into `jq` to filter for CI or release tooling.

---
## 7. Advanced Selection & Annotation
Combine revset + template for targeted output:
```
# List only divergent heads with conflicts
jj log -r 'heads(all()) & conflicts() & description(regex:"WIP")' \
  --template 'format(change_id.short()," ",subject)' --no-pager
```
Annotate ancestry path:
```
jj log -r 'trunk()::@' --template 'format(commit_id.short()," ",parents.len(),"p ",subject)'
```

---
## 8. Multi-Line Descriptions Safely
Preserve indentation for release notes:
```
format("== ", subject, " ==\n", description.indent(2))
```
Truncate verbose bodies:
```
format(subject, "\n", description.truncate(500))
```

---
## 9. Bookmark / Remote Awareness
Flag if ahead of remote using revset math outside template, then decorate:
```
jj log -r 'myfeature - myfeature@origin' \
  --template 'format("AHEAD ", change_id.short(), " ", subject)'
```

---
## 10. Common Pitfalls & Guardrails
| Pitfall | Mitigation |
|---------|-----------|
| Overly complex template hard to maintain | Start with small functional blocks, compose with `format()` |
| Unescaped quotes in JSON | Use `.json()` helper on dynamic fields |
| Performance on huge histories | Narrow revset before applying heavy template processing |
| Ambiguous multi-commit outputs for single-target command | Confirm revset resolves to exactly one commit (`jj log -r 'exactly(<expr>,1)'`) |
| Hidden commits missing | Use revset including hidden: `jj log -r 'all() & <expr>'` |

---
## 11. Progressive Enhancement Strategy
1. Prototype plain: `jj log -r <revset>`
2. Add IDs + subjects: `change_id.short() " " subject`
3. Add conditionals for conflicts/WIP.
4. Introduce structured output only if external tooling demands it.
5. External validation: run template output through script to ensure stability.

---
## 12. Example Library (Copy & Adapt)
Minimal: `change_id.short() " " subject`
WIP vs Normal: `format(if(subject.contains("WIP"),"[WIP] ",""), change_id.short(), " ", subject)`
Conflicts emphasized: `format(if(conflict,"⚠ ",""), change_id.short(), " ", subject)`
Bookmark listing: `format(change_id.short()," ",bookmarks.join(",")," ",subject)`
Parents count: `format(commit_id.short()," ",parents.len()," parents")`
JSON summary: see structured output section

---
## 13. When NOT to Use Templates
- Quick manual inspection (prefer defaults)
- Simple diff or ancestry queries
- One-off selection for a human conversation

---
## 14. Integration Hooks
- Pre-push review script: use template to generate concise change list
- Release notes generator: gather commits matching `description(regex:"^(feat|fix|BREAKING)")`
- CI validation: ensure no remaining WIP subjects via template + grep pipeline

---
## 15. Future Enhancements (TODO)
- Add examples for date pattern filtering
- Add color abstraction helpers (if introduced upstream)
- Provide ready-made JSON template snippet file

---
**Reminder**: Keep templates minimal. Over-optimization reduces clarity. Employ only after confirming plain output does not satisfy automation or communication needs.
