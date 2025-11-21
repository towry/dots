# Claude Hooks Test Suite

Automated tests for Claude session/agent tracking hooks.

## Contents

- **demo-transcript.jsonl**: Sample Claude chat transcript with `toolUseResult.agentId`
  - Session ID: `demo-session-12345678-1234-1234-1234-123456789abc`
  - Agent ID: `abcd1234`
  - Includes UUIDs, sessionIds, and leafUuids that should NOT be extracted

- **test_hooks.py**: Python test suite covering:
  - ✅ Agent ID extraction validation (8 hex chars only)
  - ✅ False positive prevention (rejects UUIDs, sessionIds, leafUuids)
  - ✅ Input sanitization (newline/injection prevention)
  - ✅ File operations and permissions (0600)
  - ✅ Transcript search with isolated environment
  - ✅ Bash command prevention (blocks find/grep, allows clean commands)

## Running Tests

```fish
cd tests/claude-hooks
python3 test_hooks.py
```

Expected output:
```
Running Claude hooks test suite...

Testing agent ID extraction:
✓ extract_agent_id_valid
✓ extract_agent_id_rejects_uuid
✓ extract_agent_id_rejects_sessionId
✓ extract_agent_id_rejects_leafUuid
✓ extract_agent_id_valid_format
✓ extract_agent_id_rejects_short
✓ extract_agent_id_rejects_long
✓ extract_agent_id_rejects_nonhex

Testing transcript search:
✓ search_transcript

Testing input sanitization:
✓ sanitize_input_removes_newlines
✓ sanitize_input_preserves_normal

Testing file operations:
✓ file_operations_create
✓ file_operations_permissions

Testing prevent forbidden bash:
✓ prevent_bash_blocks_find
✓ prevent_bash_blocks_grep
✓ prevent_bash_allows_clean_commands
✓ prevent_bash_allows_other_tools

============================================================
Test Results: 17/17 passed
============================================================
```

## CI Integration

GitHub Actions workflow (`.github/workflows/test-claude-hooks.yml`) runs automatically on:
- Push to `main` branch
- Pull requests to `main`
- Changes to hook files or test files

## Security Note

Tests verify that hooks ONLY extract `toolUseResult.agentId` and validate format `^[0-9a-fA-F]{8}$` to prevent false positives from UUIDs, sessionIds, or other identifiers.

## Related Files

- **Hooks**: `nix/hm/ai/claude/hooks/{session_remind,subagent_remind,get_last_agent}.py`
- **Config**: `.claude/settings.json`
- **Docs**: `docs/claude-hooks.md`
