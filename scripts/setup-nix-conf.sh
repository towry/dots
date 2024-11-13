#!/usr/bin/env bash

## https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-trusted-users

NIX_CONF="/etc/nix/nix.conf"
USER_NIX_CONF="$HOME/.config/nix/nix.conf"

# Check if a username is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

USERNAME="$1"

# ask for sudo permission
sudo -v

# Create config if it doesn't exist
mkdir -p /etc/nix
mkdir -p "$HOME/.config/nix"
touch "$NIX_CONF"
touch "$USER_NIX_CONF"

# Configuration lines to add
CONFIG_LINES=(
    "trusted-users = root @staff $USERNAME"
    "substituters = https://dots.cachix.org https://nix-community.cachix.org https://towry.cachix.org https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/"
    "trusted-public-keys = dots.cachix.org-1:H/gV3a5Ossrd/R+qrqrAk9tr3j51NHEB+pCTOk0OjYA= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= towry.cachix.org-1:7wS4ROZkLQMG6TZPt4K6kSwzbRJZf6OiyR9tWgUg3hY="
    "experimental-features = nix-command flakes"
)

# Function to check if line exists in file
line_exists() {
    local line="$1"
    local conf="$2"
    local key=$(echo "$line" | awk '{print $1}')

    # If the line exists with the same key, remove the old line
    if grep -q "^$key" $conf; then
        # Remove the old line
        sudo sed -i '' "/^$key/d" "$NIX_CONF"
        return true
    fi
    return false
}

# Add each configuration line if it doesn't exist
for line in "${CONFIG_LINES[@]}"; do
    if ! line_exists "$line" "$NIX_CONF"; then
        echo "$line" >> "$NIX_CONF"
        echo "> Added: $line"
    else
        echo "> Already exists: $line"
    fi

    if ! line_exists "$line" "$USER_NIX_CONF"; then
        echo "$line" >> "$USER_NIX_CONF"
        echo "> Added: $line"
    else
        echo "> Already exists: $line"
    fi
done

echo "> Nix configuration update completed"
