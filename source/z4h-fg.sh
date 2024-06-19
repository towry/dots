my-ctrl-z() {
  (( ${(%):-%j} > 0 )) && fg
}
zle -N my-ctrl-z
bindkey '^Z' my-ctrl-z
