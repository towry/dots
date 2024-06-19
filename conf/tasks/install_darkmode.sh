#!/usr/bin/env bash

Repo_Dark_Mode_Notify="https://ghproxy.com/https://github.com/pze/dark-mode-notify"

function build_dark_mode_bin() {
  if [ -f "/usr/local/bin/dark-mode-notify" ]; then
    echo "~> Bin exists"
    return
  fi
  echo "~> Installing dark mode notify daemon"
  cd /tmp
  echo "~> Clone source repo into /tmp/dark-mode-notify"
  git clone --depth 1 $Repo_Dark_Mode_Notify dark-mode-notify
  cd dark-mode-notify
  echo "~> Builing from source"
  make build
  echo "~> Install to /usr/local/bin/dark-mode-notify"
  make install
}

function install_dark_mode_notify() {
  pwd=`pwd`
  build_dark_mode_bin
  echo "~> Copy daemon file"
  cp ~/.dotfiles/conf/tasks/ke.bou.dark-mode-notify.plist ~/Library/LaunchAgents/
  cp ~/.dotfiles/conf/commands/dark_mode_changed.sh /usr/local/bin/

  echo "~> Install other deps"
  export PYENV_ROOT="$HOME/.pyenv"
  command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  pyenv shell 3.11.1
  if ! [ $? -eq 0 ]; then
    echo "missing python 3.11.1"
    exit 0
  fi

  # make sure the python deps is installed by correct pip3(not system).
  pyenv exec pip --version
  pyenv exec pip install pynvim neovim-remote

  echo "~> Launch the daemon"
  # may have errors at first install, but just ignore it.
  launchctl unload ~/Library/LaunchAgents/ke.bou.dark-mode-notify.plist
  launchctl load -w ~/Library/LaunchAgents/ke.bou.dark-mode-notify.plist
  cd $pwd
  echo "~> 👌 Done"
}

install_dark_mode_notify
