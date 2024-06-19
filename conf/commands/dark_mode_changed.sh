#!/usr/bin/env bash

echo "mode is: $DARKMODE"

exit 0

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH:/usr/local/bin:/usr/bin"
eval "$(pyenv init -)"
pyenv shell 3.11.1
if ! [ $? -eq 0 ]; then
  echo "missing python 3.11.1"
  exit 0
fi

python --version

if ! [ -x "$(command -v nvr)" ]; then
  echo "nvr command not exists"
fi

echo "running color_mode.py"
# python3 $HOME/.dotfiles/conf/commands/color_mode.py
