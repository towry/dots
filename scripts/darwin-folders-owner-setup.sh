#!/usr/bin/env bash

# some folders in /usr/local are not owned by the user

# chown -R $(whoami) ...folders

FOLDERS_LIST=(
  "/usr/local/bin"
  "/usr/local/lib"
  "/usr/local/share"
)


for folder in "${FOLDERS_LIST[@]}"; do
    mkdir -p "$folder"
done

sudo -v

for folder in "${FOLDERS_LIST[@]}"; do
    sudo chown -R $(whoami) $folder/*
done

# change owner of $HOME/Applications/Home\ Manager\ Apps/*
if [ -d "$HOME/Applications/Home Manager Apps" ]; then
    sudo chown -R $(whoami) "$HOME/Applications/Home Manager Apps"/*
fi
