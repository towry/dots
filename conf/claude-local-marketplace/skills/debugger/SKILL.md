---
name: debugger
description: Systematically trace bugs backward through call stack to find the original trigger. Use this skill when user wants to debug complex issues or has a bug that is hard to spot; user says "not working" and you are debugging an issue.
---

# When to use

- User is frustrated about your attempts
- Bugs are vague and not easy to spot
- User says debug this or debug it something like that

# Debugging process 

1. **Understand** the issue/bug 
2. **Fetch context**  Use `kg` to search the knowledge graph in case we solved this before. Use `fast-repo-context` skill(recommended) or `rg` bash tool to search the codebases with possible keywords, and read comments or documents. Get a sense of recent changes that might relate to the issue/bug. Identify relevant files and code areas. You can ask general subagent to do this for you.
3. **Review available tools** Review what tools do you have that might help you debug issues.
4. **Start debugging iterations** - Each iteration MUST be explicitly labeled (e.g., "**Iteration 1**", "**Iteration 2**")
   - 4.1 Get debugging ideas/strategy or issue qualitative analysis from `outbox` subagent with context from steps 2 and 3. Include the tools and subagents you have and what they do, so `outbox` can give advice based on your available tools.
   - 4.2 **Check git history** (if applicable): Use `git-jj` skill to investigate version history when the bug might be a regression. Run blame on suspicious lines, check recent file changes, or use bisect to find the breaking commit. See "When to use git history" section above.
   - 4.3 Follow instructions from `outbox`, trace back to the root cause of the bug/issue 
   - 4.4 Propose a fix or the root of cause to user, let user review it.
   - 4.5 Apply the fix if user agrees.
   - 4.5 Ask user to confirm the fix 
5. **Iterate** Step 4 until user has confirmed the bug/issue is resolved. Keep key findings from each iteration and feed all findings and attempted methods to `outbox` for the next iteration.

## Iteration tracking

- **Always announce iteration number** at the start: "**Iteration N**: Trying X approach..."
- Keep a mental log of what was tried in each iteration
- When consulting `outbox` after iteration 1, always include findings from ALL previous iterations

## Outbox prompt template

**Note**: `outbox` is a readonly/thinking agent. It cannot use tools (no Read, no Write, no Execute). It can only reason and advise. You must provide all relevant context in the prompt.

### First iteration:
```
**Bug**: <one-line description>
**Symptoms**: <what user observed, error messages>
**Relevant files**: <file paths found in step 2>
**Code context**: <brief snippet or description of suspicious area>

**Available tools** (I can execute these):
- rg, fd (search)
- kg (knowledge graph - check past solutions)
- git-jj (blame, file history, bisect, diff)
- Read, Grep, Glob (file inspection)
- Execute (run commands, add logs)

**Ask**: Given this bug and these tools, what debugging strategy should I follow? Provide specific actionable steps. At the end of your advice, include a "feedback request" like: "If this doesn't work, tell me [specific info] for next iteration."
```

### Subsequent iterations:
```
**Iteration**: N (where N > 1)

**Bug**: <one-line description>
**Symptoms**: <what user observed, error messages>
**Relevant files**: <file paths>
**Code context**: <brief snippet or description of suspicious area>

**Available tools** (I can execute these):
- rg, fd (search)
- kg (knowledge graph - check past solutions)
- git-jj (blame, file history, bisect, diff)
- Read, Grep, Glob (file inspection)
- Execute (run commands, add logs)

**What I tried**: <methods attempted in previous iterations>
**Findings**: <key observations, what was ruled out>
**Current hypothesis**: <if any>

**Ask**: Based on findings, what should I try next? At the end of your advice, include a "feedback request" like: "If this doesn't work, tell me [specific info] for next iteration."
```

# Tools, subagents, skills that might be helpful

- **Critical**: `fast-repo-context` claude skill for fast codebase search and analysis, this is highly recommended to use, load it with `Skill` tool; Can use it to search on current project or other projects.
- `kg` knowledge graph search, use it to find whether we have solved similar issues before.
- load `git-jj` claude skill for vcs operations (logs, blame, diff etc), use `bash ~/.claude/skills/git-jj/scripts/repo_check.sh` to check repo is jj or git managed.
  - **Debugging-specific commands:**
    - `git blame <file>` / `jj file annotate <file>` - find who changed a line and when
    - `git log -p <file>` / `jj log -p <file>` - see all changes to a specific file
    - `git bisect` - binary search for the commit that introduced a bug
    - `git diff <a>..<b>` / `jj diff -r <a>..<b>` - compare specific revisions
    - `jj log -r "file('path')"` - find commits that touched a file
- `outbox` subagent for high level debugging ideas, strategies, and issue qualitative analysis; Invoke the `Task` tool with `outbox`.
- `oracle` subagent for advanced reasoning about complex issues, decision making; Invoke the `Task` tool with `oracle`.
- `exa` mcp tool: use it to search on the web for similar issues, error messages, stack traces, and solutions.
- `github` mcp tool: use it to search library related issues in github issues.
- Other command tools that you already know

## When to use git history for debugging

Use git history when:

- **Regression bugs**: User says "it worked before", "it broke after update", recent we have a refactor or dependency upgrade etc.
- **Unknown code changes**: You find suspicious code but don't understand why it was written that way
- **Recent breakage**: Bug appeared recently and might correlate with recent commits
- **Blame investigation**: Need to find the original author/context of problematic code

Skip git history when:
- Bug is clearly a logic error in current code
- Issue is configuration or environment related
- User confirms this is new code, not a regression

## Notes

- `kg` should be used for finding key information related to the issues. Do not use it to save unverified debugging assumptions. After user confirms the fix, you can ask whether to save the fix to the knowledge graph.
- You have advanced tools, subagents and skills to debug complex issues. Do not hesitate to use them.

# Real world example 

<user>
The tree city picker does nothing when I click the input 
</user>

<assistant>
I will gather the code modules related to this issue...

> next phase 

Ok, I have located the files. Now let me check what tools and subagents might help me debug this issue, and ask `outbox` subagent for ideas.

> next phase 

**Iteration 1**: Following outbox advice, I'll check the click handler binding...

> tried approach, didn't work

**Iteration 2**: The click handler exists but event propagation might be blocked. Let me trace the event flow...

> found something suspicious

**Iteration 3**: Found it! The parent container has `pointer-events: none`. Here is the fix...

Hi, here is the root cause of this issue/bug: 

> -- omit for demo 

Please confirm it.
</assistant>

<user>
great work!
</user>
