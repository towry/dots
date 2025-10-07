---
description: "Summarize changes"
model: "glm-4.6"
permission:
  write: ask
  edit: ask
tools:
  write: true
  edit: true
  bash: false
  read: true
  glob: true
  grep: true
  list: true
  webfetch: true
mode: subagent
---

Please summarize current chat what the changes are and create/write in markdown
file located at `./llm/changes/<change-name>_change.md`.

The format is like:

```markdown
# Change Name

## Changes

- [filename1] Added, Change short description.
- [filename2] ...
- [filename4] ...
- [filename3] Deleted, short description (file deleted to remove unused code)

## Summary

A brief summary of the whole changes.

## Details

Details about the changes, why, how, etc.

## To Do List

If there any to do, not implemented code, must list here.
```
