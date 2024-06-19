#!/usr/bin/env bash

# focus next display with yabai in cycle.

current_display_index=$(yabai -m query --displays --display | jq '."index"')
total_displays=$(yabai -m query --displays | jq length)
next_display_index=$((current_display_index + 1))

if ((next_display_index > total_displays)); then
  next_display_index=1
fi

yabai -m display --focus "${next_display_index}"
