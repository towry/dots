# Claude Hooks Test Suite

Automated tests for Claude session/agent tracking hooks.

## Contents

- **demo-transcript.jsonl**: Sample Claude chat transcript with `toolUseResult.agentId`
  - Session ID: `demo-session-12345678-1234-1234-1234-123456789abc`
  - Agent ID: `abcd1234`
  - Includes UUIDs, sessionIds, and leafUuids that should NOT be extracted

- **test_hooks.py**: Python test suite covering:
  - ✅ Input sanitization (newline/injection prevention)
  - ✅ File operations and permissions (0600)
  - ✅ Bash command prevention (blocks find/grep, allows clean commands)

## Running Tests

```fish
cd tests/claude-hooks
python3 test_hooks.py
```

Expected output:
```
Running Claude hooks test suite...

Testing input sanitization:
✓ sanitize_input_removes_newlines
✓ sanitize_input_preserves_normal

Testing file operations:
✓ file_operations_create
✓ file_operations_permissions (note: hooks set 0600 explicitly)

Testing prevent forbidden bash:
✓ prevent_bash_blocks_find
✓ prevent_bash_blocks_grep
✓ prevent_bash_allows_clean_commands
✓ prevent_bash_allows_other_tools

============================================================
Test Results: 8/8 passed
============================================================
```

## CI Integration

GitHub Actions workflow (`.github/workflows/test-claude-hooks.yml`) runs automatically on:
- Push to `main` branch
- Pull requests to `main`
- Changes to hook files or test files

## Security Note

Tests verify that the `prevent_forbidden_bash` hook correctly:
- Blocks dangerous Bash commands (find, grep, jj git push, git init, etc.)
- Suggests safer alternatives (fd instead of find, rg instead of grep)
- Allows legitimate operations and non-Bash tool calls

## Related Files

- **Hooks**: `nix/hm/ai/claude/hooks/{session_remind,prevent_forbidden_bash}.py`
- **Config**: `.claude/settings.json`
- **Docs**: `docs/claude-hooks.md`
