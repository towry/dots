# 1. create new rev from main trunk.
# 2. create new bookmark from that rev.
# 3. take the rev description as bookmark name.
# 4. use  `jj-mega-merge -t m-m -f <bookmark>` to merge it into mega merge rev.
# 5. if ollama is installed, use it to generate a commit message for the mega merge rev.
# 6. otherwise, create bookmark name by `towry/jj-<year-month-day-hour-minute>`

function jj-fork-master --description "Fork master branch"
    argparse 'h/help' 'd/description=' -- $argv
    or return

    # set help string
    set -l help_string "Usage: jj-fork-master -d <description>"

    if set -ql _flag_help
        echo $help_string
        return 0
    end

    if not set -q _flag_description
        echo $help_string
        return 1
    end

    # Use the generic jj-fork function with master bookmark
    jj-fork -d $_flag_description -b master
end
