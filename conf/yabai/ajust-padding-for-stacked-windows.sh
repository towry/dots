#!/usr/bin/env sh

# exclude hammerspoon stackline icons from count; they count as windows
windows=$(yabai -m query --windows --space | jq 'map(select(."app" != "Hammerspoon"))')
window_count=$(echo $windows | jq 'length')
stack_count=$(echo $windows | jq 'map(select(."stack-index" == 1)) | length')
stacked_window_count=$(yabai -m query --windows --space | jq -c 'map(select(."stack-index" != 0)) | length')
current_space=$(yabai -m query --spaces --space | jq '.index')

default_padding=$(yabai -m config top_padding)
padding_for_stack_icons=40

top_padding=$default_padding
bottom_padding=$default_padding
left_padding=$default_padding
right_padding=$default_padding
window_gap=$default_padding

[[ "$stack_count" -gt 0 ]] && left_padding=$padding_for_stack_icons
[[ "$stack_count" -gt 1 ]] && right_padding=$padding_for_stack_icons

yabai -m config --space "$current_space" top_padding $top_padding
yabai -m config --space "$current_space" bottom_padding $bottom_padding
yabai -m config --space "$current_space" left_padding $left_padding
yabai -m config --space "$current_space" right_padding $right_padding
yabai -m config --space "$current_space" window_gap $window_gap
