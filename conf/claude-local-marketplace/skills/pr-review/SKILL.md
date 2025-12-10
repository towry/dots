---
name: pr-review
description: This skill should be used when retrieving and managing GitHub pull request reviews, particularly for accessing unresolved review comments, pending reviews, and reviewer feedback. Use this skill when asked to fetch PR review data, display pending comments, or check review status for a specific pull request. Also can be triggered by phrase like 'load pr review'
---

# PR Review

## Overview

This skill retrieves and displays unresolved GitHub pull request reviews and comments. It integrates with the GitHub CLI (`gh`) to fetch review information for the current repository, automatically detecting whether the repository uses `git` or `jj` for version control.

## When to Use This Skill
Example triggers:
- "Get pr 123 review comments"
- "Show me all pending reviews on this PR"
- "What are the unresolved comments on the current PR?"

## Prepare required information

### 1. Extract Owner/Repo

To retrieve review data, first determine the repository owner and name:

```bash
bash ~/.claude/skills/pr-review/scripts/get-owner-repo.sh
```

This script:
- Returns the result as `owner/repo`

### 2. Determine PR Number

If a PR number is not explicitly provided:
- Ask the user which PR number they want to review
- Accept the PR number as input

## pr-review SKILL: Fetch Unresolved Review Comments

Once the `owner/repo` and PR number are known, retrieve unresolved comments:

```bash
# pr-review is gh extension.
gh pr-review review view -R <owner/repo> --unresolved --pr <pr-number> --not_outdated --reviewer towry
```

**Parameters:**
- `-R <owner/repo>`: Repository identifier
- `--unresolved`: Show only unresolved comments (default behavior for this skill)
- `--pr <pr-number>`: Specific pull request number
- `--not_outdated`: Exclude outdated comments
- `--reviewer towry`: Filter by reviewer (typically the current user)

When:

- User want to fix the unresolved review comments.
- User want to know what unresolved review comments are.
