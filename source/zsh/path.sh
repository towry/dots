source "$HOME/.dotfiles/source/zsh/shutil.sh"


# nvm
# if [ -f ~/.nvm/alias/default ]; then
#     DEF_NODE_VER="$(< ~/.nvm/alias/default)"
#     DEF_NODE_BIN_PATH="$HOME/.nvm/versions/node/$DEF_NODE_VER/bin"
#     # _PATH_STR+=$DEF_NODE_BIN_PATH
#     pathadd $DEF_NODE_BIN_PATH
# else
#     echo "NO node"
# fi
# fnm
# pathadd "$FNM_DIR/aliases/default/bin"

# ==================================
pathadd "$HOME/.local/bin"
pathadd /usr/local/bin
pathadd /usr/local/opt/openssl/bin
pathadd /usr/local/sbin

