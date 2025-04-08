function jj-mega-merge --description "jj mega merge: -t <merge-to-rev> -f <merge-from-rev> -f <merge-from-rev> ..."
    argparse 'h/help' 't/to=' 'f/from=+' 'remove=' -- $argv
    or return

    # set help string
    set -l help_string "Usage: jj-mega-merge -t <merge-to-rev> [-f <merge-from-rev>]... [--remove <rev-to-remove>]"

    if set -ql _flag_help
        echo $help_string
        return 0
    end

    if set -ql _flag_remove && set -q _flag_to
        set -l target_rev $_flag_to
        set -l remove_rev $_flag_remove
        set -l command "jj rebase -s $target_rev -d \"all:$target_rev- ~ $remove_rev\""
        echo "> Removing rev: $remove_rev"
        echo "> $command"
        echo ""
        eval $command
        return 0
    end


    if not set -q _flag_to || not set -q _flag_from
        echo $help_string
        return 1
    end

    set -l from_revs $_flag_from
    set -l target_rev $_flag_to

    # jj rebase -s <target-rev> -d <from-rev> -d <from-rev> -d <from-rev> ...
    set -l command "jj rebase -s $target_rev -d all:$target_rev-"
    set -l command_with_color "jj rebase -s "(set_color blue)$target_rev(set_color normal)" -d all:"(set_color blue)$target_rev(set_color normal)"-"

    for rev in $from_revs
        set command "$command -d $rev"
        set command_with_color "$command_with_color -d "(set_color ff69b4)$rev(set_color normal)" "
    end

    echo "> $command_with_color"
    # run the command
    eval $command
end
