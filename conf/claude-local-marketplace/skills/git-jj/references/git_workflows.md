# Git Workflows Guide

**Modern Git Practices (2.30+)**

## Repository Status & Changes
- View status (tracked/untracked): `git status`
- Show unstaged changes: `git diff`
- Show staged changes: `git diff --staged` (or `--cached`)
- Show name status summary: `git diff --name-status`
- Show only names of changed files: `git diff --name-only`

## Working with Changes
- Stage all changes: `git add .`
- Stage specific file(s): `git add <file>`
- Stage patch (interactive hunk selection): `git add -p <file>`
- Unstage a file: `git restore --staged <file>` (preferred) or `git reset HEAD <file>`
- Discard local modifications in file: `git restore <file>`
- Discard ALL uncommitted changes: `git reset --hard HEAD` (DANGEROUS - confirm with user)
- Temporary save (stash): `git stash push -m "message"` then `git stash list`

## Commits
- Create commit: `git commit -m "message"`
- Create commit with all tracked modified files (skip separate add): `git commit -am "message"` (does not include new untracked files)
- Amend last commit (replace message & staged changes): `git commit --amend`
- Amend without changing message: `git commit --amend --no-edit`
- Show commit details: `git show <commit>`
- Show just commit message: `git log -1 --pretty=%B`

## History & Navigation
- Show full log: `git log`
- Compact graph: `git log --oneline --graph --decorate`
- Show author/date summary: `git log --pretty=format:'%h %ad | %s%d [%an]' --date=short`
- Show changes to specific file over time: `git log -p <file>`
- Search commit messages: `git log --grep <pattern>`
- Reflog (local history of HEAD): `git reflog`

## Branches
- List local branches: `git branch`
- List all branches (remote + local): `git branch -a`
- Create and switch: `git switch -c <name>` (preferred) or `git checkout -b <name>`
- Switch to existing: `git switch <name>`
- Delete local branch (safe): `git branch -d <name>`
- Force delete local branch: `git branch -D <name>` (confirm with user)
- Rename current branch: `git branch -m <new-name>`

## Merging & Rebasing
- Merge feature into current: `git merge <branch>`
- Rebase current onto target: `git rebase <branch>`
- Abort in-progress rebase: `git rebase --abort`
- Continue after conflict resolution: `git rebase --continue`
- Interactive rebase (N commits): `git rebase -i HEAD~N` (avoid unless user requests)

## Cherry-Pick & Revert
- Cherry-pick commit: `git cherry-pick <commit>`
- Continue cherry-pick after conflicts: `git cherry-pick --continue`
- Abort cherry-pick: `git cherry-pick --abort`
- Revert commit: `git revert <commit>` (creates new inverse commit)

## Working with Remotes
- List remotes: `git remote -v`
- Add remote: `git remote add origin <url>`
- Fetch all: `git fetch --all --prune`
- Push branch first time: `git push -u origin <branch>`
- Push regular updates: `git push`
- Pull (fetch + merge): `git pull` (consider fetch + rebase alternative)
- Pull with rebase: `git pull --rebase`
- Show remote branches: `git branch -r`

## Worktrees
- Create new worktree from branch: `git worktree add ../<dir> <branch>`
- Create worktree from HEAD (detached): `git worktree add ../<dir>`
- List worktrees: `git worktree list`
- Remove worktree: `git worktree remove ../<dir>`
- Prune stale worktrees: `git worktree prune`

## Stashing & Recovery
- List stashes: `git stash list`
- Apply latest stash (keep in list): `git stash apply`
- Pop latest stash (remove after apply): `git stash pop`
- Show stash diff: `git stash show -p stash@{0}`

## Diff & Patch Advanced
- Word diff: `git diff --word-diff` (semantic changes)
- Specific commit diff: `git diff <commit1> <commit2>`
- Diff staged vs HEAD: `git diff --cached`
- Generate patch: `git diff > changes.patch` (apply with `git apply changes.patch`)

## Safety & Best Practices
1. Confirm with user before destructive operations: `reset --hard`, branch deletion, force push
2. Prefer `switch` over `checkout` for clarity
3. Avoid rewriting published history unless explicitly approved
4. Use descriptive branch names: `feat/<scope>`, `fix/<issue>`, `chore/<task>`
5. Clean merged branches periodically: list merged with: `git branch --merged`

## Typical Feature Workflow (Example)
1. Sync main: `git fetch origin` then `git switch main` then `git pull --rebase`
2. Create branch: `git switch -c feat/<description>`
3. Work & stage changes: `git add <files>`
4. Commit: `git commit -m "feat: <description>"`
5. Push: `git push -u origin feat/<description>` (confirm first)
6. Open PR (outside scope of this reference)

## Troubleshooting
- Orphaned commit recovery: use `git reflog` then `git branch <name> <reflog-hash>`
- Resolve merge conflicts: edit files, `git add`, then `git merge --continue` or `git rebase --continue`
- Accidentally staged file: `git restore --staged <file>`
- Remove untracked files: `git clean -fd` (DANGEROUS – confirm with user)

## Mapping to JJ (Quick Parallels)
| Git Concept | JJ Concept |
|-------------|------------|
| Branch | Bookmark |
| Stash | New commit / checkpoint (jj new) |
| Worktree | Workspace |
| Rebase | Non-destructive rebase (jj rebase) |
| Cherry-pick | Duplicate (jj duplicate) |
| Amend | Describe (jj describe) |