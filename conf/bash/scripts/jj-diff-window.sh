#!/bin/bash

# Create a temporary directory in user's home to avoid /T/ path issues
temp_dir="/tmp/jj-diffs"
mkdir -p "$temp_dir"

# Create a temporary file for the diff output
tempfile="$temp_dir/jj_diff_$(date +%s)_$$.diff"
touch $tempfile
chmod 600 $tempfile

# Check if temporary file was created successfully
if [ ! -f "$tempfile" ]; then
    echo "Error: Failed to create temporary file"
    exit 1
fi

# Generate the diff and save to temporary file
if ! jj diff -r @ --no-pager --git > "$tempfile" 2>/dev/null; then
    echo "Error: Failed to generate diff"
    rm -f "$tempfile"
    exit 1
fi

# Open a new Ghostty window with nvim editing the diff file
# Do not contains "/T/", ghostty will ask for permission to execute this file
# strange
echo "$tempfile"
ghostty -e nvim "$tempfile"
