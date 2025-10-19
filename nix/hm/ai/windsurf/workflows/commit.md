---
description: Commit changes with jj
auto_execution_mode: 1
---

This repo use jj as the version control system, so you need to commit your changes with jj.

# steps to commit

1. run `jj status` to check working copy status
2. run `jj log --no-pager --no-graph -n 10 -r "trunk()..@"` to check the last 10 commits
3. run `jj git-diff -r @` to check working copy changes in diff format
4. run `jj git-diff -r rev` to check changes in specific rev, if needed

## Amend changes guideline

If you think current changes should be amend to previous commit

```
jj squash -f @ -t rev [FILESETS]
```

- `[FILESETS]` is a list of file paths to commit.
- `-f @` is using the working copy as from, you can change it to any rev.
- `-t rev` is the target commit, you can change it to any rev, you can also use `--to rev`.

## immutable changes

If you encounter error that commit or amend error due to immutable changes, you should create new commit instead of modify the immutable commit.

## If you find commits with `wip: ` prefix in the log

Those commits are working in progress, you can use `jj describe -r rev -m "new message"` to update them.

When there are wip commits, jj will refuse to push to remote, so you need to ask user wether to update wip commits or not.

## Prepare commit working copy changes

You should know which files to update, if there are files that are not supposed to commit, you should use file paths in the `jj commit` command to exclude them.

`Usage: jj commit [OPTIONS] [FILESETS]... -m "message"`

`[FILESETS]` is a list of file paths to commit.

Note, if working copy is empty, do not commit it, jj will refuse to push empty commit, if the changes is in previous commit, you can use `jj describe -r rev -m "new message"` to amend the previous commit/rev.

## commit conventions

follow the commit conventions:

- `type(scope): subject`

# post-commit check

After commit, run `jj log --no-pager --no-graph -n 10` to check the last 10 commits, ensure no empty commit between commits, no wip commit block our way to push.

Do not perform push command, let user decide wether to push or not.
