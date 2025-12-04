Resumes work from a previous handoff session which are stored in `.claude/handoffs`.

The handoff folder might not exist if there are none.

Requested handoff file: `$ARGUMENTS`

Note, the user may misspell the handoff file, you just choose the right one, never auto read the handoff without user's confirm.

## Process

### 1. Check handoff file

The handoff files is located in `<project-dir>/.claude/handoffs/`. If no handoff file was provided, and no list of handoffs in the chat, then list them all use bash. Eg:

```
ls .claude/handoffs
```

