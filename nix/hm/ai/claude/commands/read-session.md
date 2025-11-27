Read saved session transcripts from `<project-root>/.claude/sessions/` to find information from past conversations.

Session files are named: `session-<description>-<timestamp>.txt`

User query: `$ARGUMENTS`

## Process

### 1. List available sessions

If no specific session mentioned, list recent sessions:

```bash
ls -lt .claude/sessions/ | head -20
```

### 2. Read session file

Once a session is identified (by description or timestamp), read it:

```bash
cat .claude/sessions/<filename>
```

### 3. Search for specific content

If user is looking for something specific, use grep:

```bash
rg -i "<search-term>" .claude/sessions/
```

## Session file format

Sessions contain conversation in this format:
- `<user>...</user>` - User messages
- `<agent>...</agent>` - Assistant responses  
- `<tool_call>...</tool_call>` - Important tool calls (Bash, Write, Edit, Create, Task)

## Notes

- Sessions are saved when Claude session ends (via SessionEnd hook)
- Filenames include a short description from the first user message
- If `<project-root>/.claude/sessions/` doesn't exist, no sessions have been saved yet
