#!/bin/bash

# Define source and destination directories
SOURCE_DIR="$HOME/.dotfiles/conf/kitty/"
DEST_DIR="$HOME/.config/kitty/"

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Copy all files from source to destination, excluding install.sh
rsync -a --exclude='install.sh' "$SOURCE_DIR" "$DEST_DIR"

echo "All files from $SOURCE_DIR have been copied to $DEST_DIR"
