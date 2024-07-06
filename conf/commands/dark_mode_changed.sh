#!/usr/bin/env bash

export PATH="$HOME/.nix-profile/bin:$PATH"

if ! [ -x "$(command -v nvr)" ]; then
  echo "nvr command not exists"
fi


echo ""
echo "$(date)> mode is: $DARKMODE"
echo "$(date)> running color_mode.py"
python3 $HOME/.dotfiles/conf/commands/color_mode.py
