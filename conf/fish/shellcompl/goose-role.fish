# Fish completion for goose-role
# Provides completion with files from goose-recipes directory

complete -c goose-role -f -a '(fd -t f -t l -e yaml -e yml --base-directory $HOME/workspace/goose-recipes_)' -d "Recipe file"
