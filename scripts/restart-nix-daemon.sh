#!/usr/bin/env bash

sudo -v

# check is darwin using uname
if [ "$(uname)" = "Darwin" ]; then
    sudo launchctl stop org.nixos.nix-daemon
    sudo launchctl start org.nixos.nix-daemon
    echo "> Nix daemon restarted"
elif [ "$(uname)" = "Linux" ]; then
    sudo systemctl restart nix-daemon
    echo "> Nix daemon restarted"
else
    echo "> Unsupported OS type"
fi
