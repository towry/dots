# credit: https://github.com/gessen/fzf.fish/blob/master/functions/_fzf-jj-revs.fish

function _fzf-jj-revs --description "Search for jujutsu revision ids"
    jj root --quiet &>/dev/null; or return
    set -f lines (jj log --ignore-working-copy --no-graph --color always \
        --revisions 'bookmarks(towry) | (ancestors(@) & author(towry) ~ empty())' \
        --template 'author.timestamp().format("%F") ++ " " ++change_id.shortest(7) ++ " " ++ description.first_line() ++ " " ++ bookmarks ++ "\n"' \
        | fzf --tmux 98% --ansi --layout=reverse --multi \
        --preview='jj show --color=always --git --stat {2}')

    if test $status -eq 0
        set -f revs
        for line in $lines
            set -f rev (string split --field 2 " " $line)
            set -f --append revs $rev
        end

        # 检查是否在交互式shell中
        if status is-interactive
            commandline --current-token --replace (string join " " $revs)
            commandline --function repaint
        else
            # 非交互式模式下直接输出结果
            string join " " $revs
        end
    end
end

# just for testing
# _fzf-jj-revs
