#!/usr/bin/env bash

echo "mode is: $DARKMODE"

export PATH="$HOME/.nix-profile/bin:$PATH"

if ! [ -x "$(command -v nvr)" ]; then
  echo "nvr command not exists"
fi


echo "running color_mode.py"
python3 $HOME/.dotfiles/conf/commands/color_mode.py
