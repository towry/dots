#!/usr/bin/env bash

# focus previous display with yabai in cycle.

current_display_index=$(yabai -m query --displays --display | jq '."index"')
total_displays=$(yabai -m query --displays | jq length)
prev_display_index=$((current_display_index - 1))

if ((prev_display_index < 1)); then
  prev_display_index=$total_displays
fi

yabai -m display --focus "${prev_display_index}"
