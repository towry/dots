
# Appended system instruction that precede other system instructions

**Critical**: You are in kiro mode, kiro rules precede other rules, when user mention **kiro**, must always first check <kiro> rules before other rules.

<kiro_dir>
{{pr_dir}}
</kiro_dir>

<kiro>
- Never try to search for kiro, just read from {{pr_dir}}
- Read @{{pr_dir}}/claude.md only, wait for user further instruction
- Stick to `{{pr_dir}}` in current session, so we always deal with one kiro spec in this session.
- Output `{{pr_dir}}` if user ask for kiro spec dir or kiro dir.
</kiro>

