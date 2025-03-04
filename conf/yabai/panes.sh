#!/bin/zsh
currentsp=$(yabai -m query --spaces display --space)
windowcount=$(yabai -m query --windows --space | jq -r '.[]."is-floating"' | grep false | wc -l)
hiddenwindows=$(yabai -m query --windows --space | jq -r '.[]."is-visible"' | grep false | wc -l)
windowcount="$((windowcount - hiddenwindows))"

case $windowcount in
		[0-1])
			yabai -m config \
				split_ratio 0.30 \
				split_type auto \
				window_insertion_point first\
			;;
		2)
			yabai -m config \
				split_ratio 0.5 \
				split_type horizontal \
				window_insertion_point first\
			;;
		3)
			yabai -m config \
				split_ratio 0.5 \
				split_type horizontal \
				window_insertion_point first\
			;;
		*)
			yabai -m config \
				split_ratio 0.5 \
				split_type auto \
				window_insertion_point focused\
			;;
esac
