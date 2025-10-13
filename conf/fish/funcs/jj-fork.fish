# generic jj-fork function
# take arguments -b for bookmark name, -r for revision.
# if -b is provided, run git fetch first
# if -r is provided, run jj new with the revision

function jj-fork --description "Fork from a bookmark or revision"
    argparse 'h/help' 'd/description=' 'b/bookmark=' 'r/revision=' 'no-new' -- $argv
    or return

    # set help string
    set -l help_string "Usage: jj-fork -d <description> [-b <bookmark>|-r <revision>] [--no-new]
    -d, --description    Description for the new revision
    -b, --bookmark      Bookmark to fork from (will fetch from origin)
    -r, --revision      Revision to fork from (local revision, implies --no-new by default)
    --no-new            Create bookmark on existing revision without creating new commit
    -h, --help          Show this help"

    if set -ql _flag_help
        echo $help_string
        return 0
    end

    # If revision is provided, set --no-new as default
    if set -q _flag_revision
        if not set -q _flag_no_new
            set _flag_no_new true
        end
    end

    if not set -q _flag_description
        # If revision is provided, try to get commit message as description
        if set -q _flag_revision
            echo "No description provided, getting commit message from revision $_flag_revision..."
            set -l commit_message (jj --ignore-working-copy log --no-graph --quiet -r $_flag_revision -T 'description.first_line()' 2>/dev/null)
            if test $status -eq 0 -a -n "$commit_message"
                set _flag_description $commit_message
                echo "Using commit message as description: $commit_message"
            else
                echo "Error: Could not get commit message from revision $_flag_revision"
                echo $help_string
                return 1
            end
        else
            echo "Error: Description is required"
            echo $help_string
            return 1
        end
    end

    # Ensure either bookmark or revision is provided, but not both
    if set -q _flag_bookmark; and set -q _flag_revision
        echo "Error: Cannot specify both bookmark and revision"
        echo $help_string
        return 1
    end

    if not set -q _flag_bookmark; and not set -q _flag_revision
        echo "Error: Must specify either bookmark or revision"
        echo $help_string
        return 1
    end

    set -l description $_flag_description
    set -l source_ref

    # Handle bookmark case - fetch from origin
    if set -q _flag_bookmark
        set -l bookmark $_flag_bookmark
        echo "Fetching bookmark: $bookmark"
        jj --ignore-working-copy git fetch -b $bookmark > /dev/null 2>&1
        or return
        set source_ref "$bookmark@origin"
    end

    # Handle revision case - use local revision
    if set -q _flag_revision
        set source_ref $_flag_revision
    end

    # Generate bookmark name from aichat
    echo "Generating bookmark name..."
    set -l bookmark_name (aichat --role git-branch -S -c "$description")
    or return

    set -l date_now (date +%m%d%H)
    set -l bookmark_name "towry/$bookmark_name-$date_now"

    # Check if the bookmark name is already used
    jj --ignore-working-copy log --quiet -r $bookmark_name -n 1 > /dev/null 2>&1
    if test $status -eq 0
        echo "Bookmark name $bookmark_name is already used"
        return 1
    end

    set -l rev

    # If --no-new flag is set, use the source revision directly
    if set -q _flag_no_new
        echo "Creating bookmark on existing revision $source_ref..."
        set rev $source_ref
    else
        # Create new revision
        echo "Creating new revision from $source_ref..."
        set -l output (jj new --ignore-working-copy --no-pager --no-edit -r $source_ref -m "[JJ]: $description" 2>&1)
        if test $status -ne 0
            echo "Failed to create new revision"
            echo $output
            return 1
        end

        # Extract revision ID from output
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
    end

    # Create bookmark pointing to the revision
    echo "Creating bookmark pointing to $rev: $bookmark_name"
    jj bookmark set -r $rev "$bookmark_name"
    or return

    if set -q _flag_no_new
        echo "Successfully created bookmark '$bookmark_name' pointing to existing revision $rev"
    else
        echo "Successfully created bookmark '$bookmark_name' pointing to revision $rev"
    end
end
