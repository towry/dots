# Fish completion for goose-run-plan
# Provides completion with .md files using fd

complete -c goose-run-plan -f -a '(fd --type f --extension md | string replace -r ".*/" "")' -d "Markdown plan file"
