---
description: "Check each diff chunk exhaustively, list all changes that could introduce the issue, no prioritization, no conclusions."
argument-hint: [issue-description]
allowed-tools: Task(diff-issue:*), Bash(jj:*), Bash(minimize-git-diff-llm:*), Task(sage:*),
---

# Understand issue

- Analyze the issue `$ARGUMENTS` carefully, make sure you understand the issue fully.
- The user may only provide a brief description, you need to think about the possible implications of the issue in the codebase. For example, user says "xxx is broken, not work", you need to think about what could cause "xxx" to be broken, what are the possible scenarios, what are the possible components involved, etc.
- Ask the user for actual behavior and expected behavior.
- Only begin after you have a full understanding of the issue.

# Prepare context for diff-issue subagent

- Ask sage subagent to analyze the event flow or data flow that related to the issue, prepare it for the diff-issue subagent.
- Provide project patterns and frameworks context to the diff-issue subagent.
- Summarize the issue in your own words, prepare the final issue for later use.

# Find Baseline Change ID

Get the 50th change ID from trunk to HEAD:

*criticle: Run below command exactly, do not change it!, you can only change the 50 number*

```bash
jj log --no-pager --ignore-working-copy --no-graph -r "trunk()..@" -n 50 -T 'change_id.short() ++ "\n"' | tail -n 1
```

Always use `--from <rev>` and `--to <rev>` to specify revset.

Save this change ID as `<baseline-id>`.

- `trunk()` = master or main branch
- `@` = HEAD commit

## Get Full Diff Range

Generate the complete diff from baseline to HEAD and save to `/tmp/llm/diff/` folder with minimize-git-diff-llm shell command:

```bash
jj diff --git --no-pager --ignore-working-copy --context 0 --from "<baseline-id>" --to @ | minimize-git-diff-llm --save --save-path /tmp/llm/diff/

# list generated diff chunk files
ls /tmp/llm/diff/
```

The chunk files are named as `chunk_<suffxi>.diff`, where `<suffix>` is from `aa` to `zz`.

# Call diff-issue subagent with Every Diff Chunk Exhaustively

For each chunk file collect review feed back from subagent "diff-issue" with Task tool, ask "diff-issue" with chunk file path, if this change will introduce the issue, require diff-issue to simply answer "yes" or "no"; require diff-issue to only give review related to our issue, no simple style or formatting issues, only functional issues that could cause the problem.

# Final Report

- List all the diff changes which is not functional or wired up with the system.
- Do not prioritization the changes
