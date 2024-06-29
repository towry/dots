export PATH="$HOME/.nix-profile/bin:$PATH"
#!/usr/bin/env bash

# Query windows info in current space
windows_info=$(yabai -m query --windows --space)

# Filter windows where "is-visible" is true and "is-minimized" is false
filtered_windows=$(echo "$windows_info" | jq '[.[] | select(.["is-visible"] == true and .["is-minimized"] == false)]')

# Focus the first window
first_window=$(echo "$filtered_windows" | jq -r 'map(.id) | .[0]')
if [ -n "$first_window" ] && [ "$first_window" != "null" ]; then
    yabai -m window --focus "$first_window"
fi
