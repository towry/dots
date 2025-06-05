# Fish completion for glab-new-pr alias
# This provides git branch completion for the glab-new-pr command

# Complete with git branches (local and remote) sorted by commit date
complete -c glab-new-pr -f -a '(git branch -a --sort=-committerdate 2>/dev/null | string replace -r "^\s*[\*\+]?\s*" "" | string replace -r "^remotes/[^/]+/" "" | awk "!seen[\$0]++" 2>/dev/null)' -d "Create GitLab merge request for branch"
