# usage: jj-review -r <revset>
# get diff by run jj diff -r "trunk()..<revset>" -n 10 --git --no-pager
# then pass the diff to aichat with role file: conf/llm/aichat/roles/vue-review.md
function jj-review --description "Review code with AI"
    argparse 'r/revset=' -- $argv
    or return

    set -l revset $_flag_revset
    set -l diff (jj diff -r "trunk()..$revset" --git --no-pager -w --context 800)
    echo "Reviewing diff for revset: $revset"
    set -l review_result (aichat --role vue-review -S -c $diff)
    echo $review_result
end
