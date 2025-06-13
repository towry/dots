function _fzf-jj-bookmarks-git --description "fzf for git branches"
    set -l query ""
    if status is-interactive
        set query (commandline --current-token)
    end
    if git rev-parse --git-dir &>/dev/null
        set -f lines (git branch --sort=-committerdate --color=always | sed 's/^[* ] //' | fzf --cycle --tmux 98% --ansi --layout=reverse \
            --scheme=path \
            --query="$query" \
            --preview='git log --color=always --oneline -10 {}' \
            --preview-label='Recent Commits' \
            --bind='ctrl-y:execute-silent(echo {} | pbcopy)' \
            --header='Enter: select branch, Ctrl-Y: copy branch name' \
            --border=rounded)

        if test $status -eq 0
            set -l branch (echo $lines | string trim)
            if status is-interactive
                commandline --current-token --replace $branch
                commandline --function repaint
            else
                echo $branch
            end
            return 0
        end
    end
    return 1
end

function _fzf-jj-bookmarks-jj --description "fzf for jj bookmarks"
    set -l query ""
    if status is-interactive
        set query (commandline --current-token)
    end
    if jj root --ignore-working-copy --quiet &>/dev/null
        set -f lines (jj bookmark list --ignore-working-copy --sort committer-date- --quiet --no-pager --color always | grep -v '^[[:space:]]' | grep -v '\(deleted\)' | fzf --cycle --tmux 98% --ansi --layout=reverse \
            --scheme=path \
            --query="$query" \
            --preview='jj log --color=always -r "stack($(echo {} | cut -d: -f2 | awk "{print \\$1}" | string trim))" --no-graph' \
            --preview-label='Commit Details' \
            --bind='ctrl-y:execute-silent(echo {} | cut -d: -f2 | awk "{print \\$1}" | string trim | pbcopy)' \
            --header='Enter: select bookmark, Ctrl-Y: copy revset' \
            --border=rounded)

        if test $status -eq 0
            set -l bookmark (echo $lines | cut -d: -f1 | string trim)
            if status is-interactive
                commandline --current-token --replace $bookmark
                commandline --function repaint
            else
                echo $bookmark
            end
            return 0
        end
    end
    return 1
end

function _fzf-jj-bookmarks --description "Search for jujutsu bookmarks or git branches"
    # Change the order here to switch priority
    _fzf-jj-bookmarks-jj; or _fzf-jj-bookmarks-git; or begin
        echo "Not in a jj or git repository" >&2
        return 1
    end
end

# _fzf-jj-bookmarks
