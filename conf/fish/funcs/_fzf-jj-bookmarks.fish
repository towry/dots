function _fzf-jj-bookmarks --description "Search for jujutsu bookmarks"
    jj root --quiet &>/dev/null; or return
    set -f lines (jj bookmark list --color always | grep -v '^[[:space:]]' | fzf --tmux 98% --ansi --layout=reverse \
        --scheme=path \
        --preview='jj log --color=always -r "stack($(echo {} | cut -d: -f2 | awk "{print \$1}" | string trim))" --no-graph' \
        --preview-label='Commit Details' \
        --bind='ctrl-y:execute-silent(echo {} | cut -d: -f2 | awk "{print \$1}" | string trim | pbcopy)' \
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
    end
end

# _fzf-jj-bookmarks
