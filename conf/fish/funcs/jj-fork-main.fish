# 1. create new rev from main trunk.
# 2. create new bookmark from that rev.
# 3. take the rev description as bookmark name.
# 4. use  `jj-mega-merge -t m-m -f <bookmark>` to merge it into mega merge rev.
# 5. if ollama is installed, use it to generate a commit message for the mega merge rev.
# 6. otherwise, create bookmark name by `towry/jj-<year-month-day-hour-minute>`

function jj-fork-main --description "Fork main branch"
    argparse 'h/help' 'd/description=' -- $argv
    or return

    # set help string
    set -l help_string "Usage: jj-fork-main -d <description>"

    if set -ql _flag_help
        echo $help_string
        return 0
    end

    if not set -q _flag_description
        echo $help_string
        return 1
    end

    set -l description $_flag_description
    jj git fetch -b main > /dev/null 2>&1
    or return

    # create bookmark name from aichat
    echo "Generating bookmark name..."
    set -l bookmark_name (aichat --role git-branch -S -c "$description")
    or return

    set -l date_now (date +%m%d%H)
    set -l bookmark_name "$bookmark_name-$date_now"

    # check if the bookmark name is already used
    # by running jj log -r $bookmark_name -n 1
    # if no error, then the bookmark name is already used
    # exit with error msg
    jj log -r $bookmark_name -n 1 > /dev/null 2>&1
    if test $status -eq 0
        echo "Bookmark name $bookmark_name is already used"
        return 1
    end

    # 确保我们能捕获所有输出，包括stderr
    set -l output (jj new --no-pager --no-edit -r main@origin -m "$description" 2>&1)
    if test $status -ne 0
        echo "Failed to create new revision"
        return 1
    end

    # 将输出按行分割，然后在每行中查找commit ID
    set -l rev
    for line in (string split \n -- $output)
        set -l match (string match -r 'Created new commit ([a-z]+)' $line)
        if test (count $match) -eq 2
            set rev $match[2]
            break
        end
    end

    if test -z "$rev"
        echo "Failed to extract revision ID from output: $output"
        return 1
    end

    echo "Created new revision: $rev"

    echo "Creating bookmark point to $rev: $bookmark_name"
    jj bookmark set -r $rev "$bookmark_name"
    or return
end
