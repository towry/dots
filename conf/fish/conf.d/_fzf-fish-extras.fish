status is-interactive || exit

function _fzf-fish-key-bindings --on-variable fish_key_bindings
    set -l modes
    if test "$fish_key_bindings" = fish_default_key_bindings
        set modes default insert
    else
        set modes insert default
    end

    bind --mode $modes[1] \ci,\cj _fzf-jj-revs
end

_fzf-fish-key-bindings

function _fzf-uninstall --on-event fzf_uninstall
    string collect (
    bind --all | string replace --filter --regex -- "_fzf-.*" --erase
    ) | source
    functions --erase (functions --all | string match "_fzf-kill-*")
end
