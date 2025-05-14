# for mega-merge rev `m-m`
# find heads of m-m that is ancestor of rev.
# if found as <found>, first run `jj-mega-merge -t m-m -f <rev>`
# then run `jj-mega-merge -t m-m --remove <found>`

function jj-mega-up --description "update mega-merge-heads"
    argparse 'h/help' 't/to=' -- $argv
    or return
    # to default to m-m

    # set help string
    set -l help_string "Usage: jj-mega-up [--to <merge-to-rev>] <from-rev>"

    if set -ql _flag_help
        echo $help_string
        return 0
    end

    # to default to m-m
    set -l target_rev $_flag_to
    if not set -q target_rev || test -z "$target_rev"
        set target_rev "m-m"
    end
    if test -z "$target_rev"
        echo "Missing <target-rev> parameter"
        echo $help_string
        return 1
    end

    set -l from_rev $argv[1]
    if not set -q from_rev || test -z "$from_rev"
        echo "Missing <from-rev> parameter"
        echo $help_string
        return 1
    end

    # 查找 trunk()..$from_rev & parents($target_rev)
    set -l found_revs (jj log --quiet -r "(trunk()..$from_rev) & parents($target_rev) ~ $from_rev" --no-graph --template 'change_id.shortest(7) ++ " \t" ++ description.first_line()' --no-pager)
    set -l found_count (count $found_revs)

    if test $found_count -eq 0
        echo "Parent node not found，update "(set_color yellow)$from_rev(set_color normal)" to mega-merge node ("(set_color yellow)$target_rev(set_color normal)") parents"
        # echo "> jj-mega-merge -t $target_rev -f $from_rev"
        jj-mega-merge -t $target_rev -f $from_rev
        return 0
    end

    set -l pick_rev
    if test $found_count -eq 1
        set pick_rev (string split " " $found_revs[1])[1]
    else if test $found_count -gt 1
        set -l pick_line (printf '%s\n' $found_revs | fzf --ansi --layout=reverse --prompt='选择要移除的父节点: ')
        if test -z "$pick_line"
            echo "未选择任何节点"
            return 1
        end
        set pick_rev (string split " " $pick_line)[1]
    end

    echo "To remove: "(set_color red)$pick_rev(set_color normal)

    # 先合并
    # echo "jj-mega-merge -t $target_rev -f $from_rev"
    jj-mega-merge -t $target_rev -f $from_rev
    # 再移除
    # echo "jj-mega-merge -t $target_rev --remove $pick_rev"
    jj-mega-merge -t $target_rev --remove $pick_rev
end

# jj-mega-up $argv
