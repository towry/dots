#!/usr/bin/env bash

echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) —load-sa" | sudo tee /private/etc/sudoers.d/yabai

echo "$(date): need load sa"
sudo nvram boot-args=-arm64e_preview_abi
sudo yabai --load-sa
