#!/usr/bin/bash

export DOTFILES="$HOME/.dotfiles"
source ~/.dotfiles/source/zsh/shutil.sh
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export WATCHMAN_CONFIG_FILE="$HOME/.config/watchman.json"

alias cls="clear"
alias gts="git status"
alias gst="gitaware -p ."
alias gac='echo "$(tput bold)$(tput setaf 3)warning: be carefull$(tput sgr0)" && git add . && git commit'
alias gcz='echo "$(tput bold)$(tput setaf 3)warning: be carefull$(tput sgr0)" && git add . && git cz'
alias gtail="git rev-list --all | tail"
alias xmerge="git merge --no-ff"
alias xmerged="git branch --merged master"
alias pn="pnpm"
alias g="git"
alias lg="lazygit"
alias clean-git-branch='git fetch --all && git branch -vv | awk "/: gone]/{print \$1}" | xargs git branch -D'
alias docker-exec="docker exec -it"
alias docker-logs="/bin/bash ~/.dotfiles/source/docker-logs"
alias kickstart_yabai='launchctl kickstart -k "gui/${UID}/homebrew.mxcl.yabai"'
alias tmuxnew="tmux new -s main"
alias tmuxin="tmux attach-session -t main"
alias pname="tmux select-pane -T"
alias vi="nvim"
alias tmuxconf="nvim ~/.dotfiles/conf/tmux-config/tmux/tmux.conf"
alias kittyconf="nvim ~/.config/kitty/kitty.conf"
# alias yabaiconf="nvim ~/.config/yabai/yabairc"
alias skhdconf="nvim ~/.config/skhd/skhdrc"
alias catt="bat --theme=\"\$(defaults read -globalDomain AppleInterfaceStyle &> /dev/null && echo 'Everforest Dark' || echo 'Everforest Light')\""
alias brew_upgrade_nvim="brew upgrade neovim --fetch-HEAD"
alias dot-proxy="export https_proxy=http://127.0.0.1:1080 http_proxy=http://127.0.0.1:1080 all_proxy=socks5://127.0.0.1:1080"
alias download-init-lua="curl -L -o init.lua https://gist.githubusercontent.com/towry/f16d4aac489154095c478256e53a1fb9/raw/81a3838883965ddece49c1f597bf8ee32141587d/repro.lua"
alias list-zombie-ps="ps aux | grep -w Z"
alias :qa="exit"
# parent-pid-of {pid}
alias parent-pid-of="ps o ppid"
# kill -1 {pid}

# export RUSTUP_DIST_SERVER="https://mirrors.tuna.tsinghua.edu.cn/rustup"

# NVM
export NVM_DIR="$HOME/.nvm"
nvm() {
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
	nvm "$@"
}

# loadrsvm() {
# 	[[ -s $HOME/.rsvm/rsvm.sh ]] && . $HOME/.rsvm/rsvm.sh # This loads RSVM
# }

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export BUN_INSTALL="$HOME/.bun"

source "$DOTFILES/source/zsh/fnm.sh"
#>>>>> PATH <<<<<<
source "$DOTFILES/source/zsh/path.sh"
#>>>>> END PATH <<<<<<


# >>> source
# source "$DOTFILES/vendor/z/z.sh"
source "$DOTFILES/source/zoxide.sh"
# Platform specific source
if type "uname" > /dev/null && [[ $(uname -s) == Linux ]]
then
	source "$DOTFILES/source/zsh/debian_zshrc.sh"
else
	source "$DOTFILES/source/zsh/osx_zshrc.sh"
fi

if type "fzf" > /dev/null; then
	source "$DOTFILES/source/fzf.sh"
fi

[ -f "$DOTFILES/source/private.sh" ] && source "$DOTFILES/source/private.sh"
# bunjs bash completion.
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
# <<<
