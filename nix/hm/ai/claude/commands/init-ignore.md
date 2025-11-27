---
description: "Init .ignore file in project root"
argument-hint: [prompt]
---

# User input (if any)

$ARGUMENTS

# Principles

- Use git ignore syntax in the .ignore file, do not try to list all files, use patterns and wildcards.
- The .ignore file is for files that should be excuded in codebase research but need to be in git, like binary font files, image files etc.
- Do not include files that are already in .gitignore.

# Workflow

Read .gitignore check what already is ignored.

Use rg and fd bash tool for codebase analysis, then generate a .ignore file in the project root based on the analysis, make sure those file patterns are in the ignore file:

- Run bash `exa --tree --git-ignore` to list the project files in a tree structure, check what files are there.
- Temporary files created by editors (e.g., swap files, backup files)
- Font files 
- Image files 
- Build artifacts (e.g., compiled binaries, object files)
- Log files
- vendor, dist files that bundled in the git, like xx.dist.js.
- Vite public folder files if any.
- Third library files, like monaco editor files, acme editor files etc.
- Files that not helpful when doing codebase research.
- Some dot files, like `.claude`, `.vscode`, `.idea` etc, those are not usefull for codebase research.

# Output 

Proper .ignore file should be generated or updated in the project root, output a diff of the changes made.
