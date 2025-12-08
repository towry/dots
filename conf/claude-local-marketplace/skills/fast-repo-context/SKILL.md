---
name: fast-repo-context
description: "Use when: exploring code, search code snippets, finding implementations by intent, understanding how features work. Triggers: [fast context], [search code], [find where], [how does X work], [understand codebase], [research codebase], [find X], [locate X], [code search], [grep code], [where is], [let me search]."
---

## bash tools

- Use `rg` to grep file content, use `fd` to find files.
- Run `bunx repomix ./` will generate `repomix-output.xml` file in repo root contains codebase index, you can use grep to search in it quickly.

## Examples

**Find files by name:**

```bash
# .nix files
fd -e nix
# .tsx files
fd -e tsx
# Files named "config" in src/
fd "config" src/
# .nix files with "config" in name
fd -e nix "config"
# .nix files with "config" in name in nix/ directory
fd -e nix "config" nix/
# Exclude pattern
fd -e nix "config" --exclude "node_modules"
# Exclude multiple patterns
fd -e nix "config" --exclude "*.test.nix" --exclude "ai"
```

**Search file content:**

```bash
# Exact phrase
rg "function handleClick"
# Regex pattern
rg "export.*useHook"
# Show 2 lines after match
rg -A 2 "TODO"
# In .nix files with pattern match
rg -t nix "export"
# In .tsx files with pattern match
rg -t tsx "TODO"
# Fixed string search (literal, not regex)
rg -F "TODO:"
# Search with glob pattern
rg "export" --glob "*.nix"
# Search in specific directory with glob
rg "TODO" --glob "conf/**"
# Exclude pattern with !
rg "TODO" --glob "!node_modules"
# Include directory, exclude files matching pattern
rg "TODO" --glob "nix/**" --glob "!**/*test*"
```

**Search in repomix index:**

```bash
bunx repomix ./

rg "search term" repomix-output.xml | head -20
rg "search term" repomix-output.xml | tail -10
```

Once you get the concrete file paths or code snippets, you can use `rg` or `fd` again to further narrow down or explore related code.
