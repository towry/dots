#!/usr/bin/env bash


function install_nix() {
    sh <(curl https://mirrors.tuna.tsinghua.edu.cn/nix/latest/install) --daemon

}

function clone_dotfiles() {
    if [[ -d $HOME/.dotfiles ]]; then
        echo "> Dotfiles already cloned."
        echo "> Move it to .dotfiles_bak"
        mv $HOME/.dotfiles $HOME/.dotfiles_bak
    fi

    git clone git@gitlab.com:towry/dots.git $HOME/.dotfiles
}

function main() {
    if [ "$1" == "clone" ]; then
        clone_dotfiles
    elif [ "$1" == "nix" ]; then
        install_nix
    else
        echo "> Invalid argument. (clone, nix)"
        exit 1
    fi
}

main "$@"
