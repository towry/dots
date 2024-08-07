{
  pkgs,
  config,
  ...
}: {
  home.packages = [
    pkgs.skhd
    pkgs.jq
    # pkgs.bash
  ];
  home.file."${config.home.homeDirectory}/Applications/skhd".source = "${pkgs.skhd}/bin/skhd";
  xdg.configFile = let
    jqbin = "${pkgs.jq}/bin/jq";
    bashbin = "${pkgs.bash}/bin/bash";
    skhdDir = "${config.xdg.configHome}/skhd";
    skhd = "${pkgs.skhd}/bin/skhd";
    bash = "${pkgs.bash}/bin/bash";
  in {
    "skhd/skhdrc".text = ''
      # https://github.com/nikhgupta/dotfiles/blob/c545755f782cd1cee90c7a7307ff17f730c18e09/config/skhd/skhdrc
      # @see key code: https://github.com/koekeishiya/skhd/issues/1
      # see: https://github.com/solomonbroadbent/dotfiles/blob/2f6c660c15e2050785ed1f08aaf89c199ffacc3d/.skhdrc#L1
      # see keyboard codes: https://cloud.githubusercontent.com/assets/6175959/18551554/35137fc6-7b59-11e6-81a0-bef19ed5db5e.png
      # powerfull mode declaration
      :: default

      :: mode_window @
      :: mode_window_move @
      :: mode_window_move_space @
      :: mode_window_move_display @
      :: mode_window_toggle @
      :: mode_window_stack @
      :: mode_window_resize @

      :: mode_space @
      :: mode_space_arrange @

      :: mode_display @

      # define escape as exit from every mode
      mode_window < escape ; default
      mode_window_move < escape ; default
      mode_window_move_space < escape ; default
      mode_window_move_display < escape ; default
      mode_window_toggle < escape ; default
      mode_window_stack < escape ; default
      mode_window_resize < escape ; default
      mode_space < escape ; default
      mode_space_arrange < escape ; default
      mode_display < escape ; default

      # define mode entry
      ctrl+shift+alt - space ; default
      ctrl+shift+alt - w ; mode_window
      mode_window < m ; mode_window_move
      mode_window_move < s ; mode_window_move_space
      mode_window_move < d ; mode_window_move_display
      mode_window < t ; mode_window_toggle
      mode_window < s ; mode_window_stack
      mode_window < r ; mode_window_resize

      ctrl+shift+alt - s ; mode_space
      mode_space < a ; mode_space_arrange

      ctrl+shift+alt - d ; mode_display

      ## ==== some applications
      cmd - return : ${bash} ${skhdDir}/yabai-focus-or-launch.sh "Firefox" "/Applications/Firefox.app/Contents/MacOS/Firefox"
      cmd + shift - return : ${bash} ${skhdDir}/yabai-focus-or-launch.sh "kitty" "${pkgs.kitty}/bin/kitty"

      ## ==============  manage windows
      mode_window < x : yabai -m window --close; skhd -k "escape"
      mode_window < return : yabai -m window --toggle zoom-fullscreen; skhd -k "escape"
      # current window will be in float state, out control of current space layout.
      mode_window_toggle < f : yabai -m window --toggle float; skhd -k "escape"
      # make current window stick to current space layout.
      mode_window_toggle < a : yabai -m window --toggle sticky; skhd -k "escape"

      mode_window < h : yabai -m window --focus west; ${skhd} -k "escape"
      mode_window < j : yabai -m window --focus south; ${skhd} -k "escape"
      mode_window < k : yabai -m window --focus north; ${skhd} -k "escape"
      mode_window < l : yabai -m window --focus east; ${skhd} -k "escape"

      # not working?
      mode_window < 0x2F : yabai -m window --focus recent; skhd -k "escape" # 0x2F is the next macos virtual key code
      mode_window < tab : yabai -m window --focus next || yabai -m window --focus first; skhd -k "escape" #0x30: tab
      # see: https://github.com/koekeishiya/yabai/issues/203
      # mode_window < tab : if [ "$(yabai -m query --spaces --space | ${jqbin} -r '.type')" = "stack" ]; then (yabai -m window --focus stack.next || yabai -m window --focus stack.first); else yabai -m window --focus next || yabai -m window --focus first; fi; skhd -k "escape"

      # focus next|prev window.
      # https://github.com/koekeishiya/yabai/issues/203#issuecomment-1289940339
      ctrl+shift+alt - h : yabai -m query --spaces --space ${jqbin} -re ".index" | xargs -I{} yabai -m query --windows --space {} | ${jqbin} -sre 'add | map(select(."is-minimized"==false)) | map(select(."has-ax-reference"==true)) | sort_by(.display, .frame.y, .frame.x, .id) | . as $array | length as $array_length | index(map(select(."has-focus"==true))) as $has_index | if $has_index > 0 then nth($has_index - 1).id else nth($array_length - 1).id end' | xargs -I{} yabai -m window --focus {}
      ctrl+shift+alt - l : yabai -m query --spaces --space | ${jqbin} -re ".index" | xargs -I{} yabai -m query --windows --space {} | ${jqbin} -sre 'add | map(select(."is-minimized"==false)) | map(select(."has-ax-reference"==true)) | sort_by(.display, .frame.y, .frame.x, .id) | . as $array | length as $array_length | index(map(select(."has-focus"==true))) as $has_index | if $array_length - 1 > $has_index then nth($has_index + 1).id else nth(0).id end' | xargs -I{} yabai -m window --focus {}

      # toggle mission control in current space
      ## show mission control preview of other spaces.
      ## see: https://github.com/koekeishiya/yabai/issues/147
      ## for cliclick issue(move): https://github.com/BlueM/cliclick/issues/168#issuecomment-1575103405
      ## you might need to sleep shortly for consistency
      ## yabai -m space --toggle mission-control && cliclick -r w:10 m:0,0
      # -r: restore initial position after move.
      # w:250 wait for 250ms after each event.
      # m:0,0, move to 0,0 coords.
      ctrl+shift+alt - g : yabai -m space --toggle mission-control && cliclick -w 250 -r m:0,0 m:1,1 w:250

      # moving windows
      mode_window_move < h : yabai -m window --warp west; skhd -k "escape"
      mode_window_move < j : yabai -m window --warp south; skhd -k "escape"
      mode_window_move < k : yabai -m window --warp north; skhd -k "escape"
      mode_window_move < l : yabai -m window --warp east; skhd -k "escape"

      # move window to space — follow focus to destination
      mode_window_move_space < 0x2F : yabai -m window --space recent; yabai -m space --focus recent; skhd -k "escape"
      mode_window_move_space < p : yabai -m window --space prev; yabai -m space --focus prev; skhd -k "escape";
      mode_window_move_space < n : yabai -m window --space next; yabai -m space --focus next; skhd -k "escape";

      mode_window_move_space < 1 : yabai -m window --space 1; yabai -m space --focus 1; skhd -k "escape"
      mode_window_move_space < 2 : yabai -m window --space 2; yabai -m space --focus 2; skhd -k "escape"
      mode_window_move_space < 3 : yabai -m window --space 3; yabai -m space --focus 3; skhd -k "escape"
      mode_window_move_space < 4 : yabai -m window --space 4; yabai -m space --focus 4; skhd -k "escape"
      mode_window_move_space < 5 : yabai -m window --space 5; yabai -m space --focus 5; skhd -k "escape"
      mode_window_move_space < 6 : yabai -m window --space 6; yabai -m space --focus 6; skhd -k "escape"
      mode_window_move_space < 7 : yabai -m window --space 7; yabai -m space --focus 7; skhd -k "escape"
      mode_window_move_space < 8 : yabai -m window --space 8; yabai -m space --focus 8; skhd -k "escape"
      mode_window_move_space < 9 : yabai -m window --space 9; yabai -m space --focus 9; skhd -k "escape"

      # move window to display
      mode_window_move_display < 1 : yabai -m window --display 1; yabai -m window --focus recent; skhd -k "escape"
      mode_window_move_display < 2 : yabai -m window --display 2; yabai -m window --focus recent; skhd -k "escape"
      mode_window_move_display < 3 : yabai -m window --display 3; yabai -m window --focus recent; skhd -k "escape"
      mode_window_move_display < 4 : yabai -m window --display 4; yabai -m window --focus recent; skhd -k "escape"
      # move window to next display or prev display
      mode_window_move_display < p : yabai -m window --display prev; skhd -k "escape"
      mode_window_move_display < n : yabai -m window --display next; skhd -k "escape"

      # stack windows
      mode_window_stack < h : yabai -m window --stack west; skhd -k "escape"
      mode_window_stack < j : yabai -m window --stack south; skhd -k "escape"
      mode_window_stack < k : yabai -m window --stack north; skhd -k "escape"
      mode_window_stack < l : yabai -m window --stack east; skhd -k "escape"

      mode_window_stack < u : yabai -m window --insert stack; skhd -k "escape"

      # resize windows — use shift to shrink
      mode_window_resize < h : yabai -m window --resize left:-25:0 | yabai -m window --resize right:-25:0
      mode_window_resize < j : yabai -m window --resize bottom:0:25 | yabai -m window --resize top:0:25
      mode_window_resize < k : yabai -m window --resize top:0:-25 | yabai -m window --resize bottom:0:-25
      mode_window_resize < l : yabai -m window --resize right:25:0 | yabai -m window --resize left:25:0

      ## >>>>>>>>>>>>>>>>> manage spaces
      mode_space < i : yabai -m space --create; skhd -k "escape"
      mode_space < x : yabai -m space --destroy; skhd -k "escape"

      mode_space < r : yabai -m space --rotate 270; skhd -k "escape"
      mode_space < b : yabai -m space --balance; skhd -k "escape"

      # recent space.
      mode_space < tab : yabai -m space --focus recent; skhd -k "escape"
      # mode_space < n : yabai -m space --focus recent; skhd -k "escape"
      # next prev space.
      # mode_space < l: yabai -m space --focus next; skhd -k "escape"
      # mode_space < h : yabai -m space --focus prev; skhd -k "escape"
      mode_space < n : ${bash} ${skhdDir}/space_cycle_next.sh;
      mode_space < p : ${bash} ${skhdDir}/space_cycle_prev.sh;
      ctrl+shift+alt - n : ${bash} ${skhdDir}/space_cycle_next.sh;
      ctrl+shift+alt - p : ${bash} ${skhdDir}/space_cycle_prev.sh;

      # goto space by index
      mode_space < 1 : yabai -m space --focus 1; skhd -k "escape"
      mode_space < 2 : yabai -m space --focus 2; skhd -k "escape"
      mode_space < 3 : yabai -m space --focus 3; skhd -k "escape"
      mode_space < 4 : yabai -m space --focus 4; skhd -k "escape"
      mode_space < 5 : yabai -m space --focus 5; skhd -k "escape"
      mode_space < 6 : yabai -m space --focus 6; skhd -k "escape"
      mode_space < 7 : yabai -m space --focus 7; skhd -k "escape"
      mode_space < 8 : yabai -m space --focus 8; skhd -k "escape"
      mode_space < 9 : yabai -m space --focus 9; skhd -k "escape"

      # change space layout
      mode_space_arrange < s : yabai -m space --layout stack; skhd -k "escape"; ${bash} ${skhdDir}/notify.sh "Space layout" "Stack"
      mode_space_arrange < f : yabai -m space --layout float; skhd -k "escape"; ${bash} ${skhdDir}/notify.sh "Space layout" "Float"
      mode_space_arrange < t : yabai -m space --layout bsp; skhd -k "escape"; ${bash} ${skhdDir}/notify.sh "Space layout" "BSP"

      ## ========== manage display
      mode_display < r : yabai --restart-service; skhd -k "escape"
      # recent display
      mode_display < tab : yabai -m display --focus recent; skhd -k "escape"
      # mode_display < n : yabai -m display --focus recent; skhd -k "escape"
      # next prev display
      mode_display < n : ${bash} ${skhdDir}/display_cycle_next.sh; skhd -k "escape"
      mode_display < p : ${bash} ${skhdDir}/display_cycle_prev.sh; skhd -k "escape"
      ctrl+shift+alt - j : ${bash} ${skhdDir}/display_cycle_next.sh
      ctrl+shift+alt - k : ${bash} ${skhdDir}/display_cycle_prev.sh
      # go to display from 1 to 4
      mode_display < 1 : yabai -m display --focus 1; skhd -k "escape"
      mode_display < 2 : yabai -m display --focus 2; skhd -k "escape"
      mode_display < 3 : yabai -m display --focus 3; skhd -k "escape"
      mode_display < 4 : yabai -m display --focus 4; skhd -k "escape"
      # >>>>>>> end display
    '';

    # ========== scripts
    "skhd/yabai-focus-or-launch.sh".text = ''
       #!${bashbin}

       set -x

       let wid=$(yabai -m query --windows | jq "[.[] | select(.app == \"$1\") | .id][0]")
       echo "$wid"

       if [[ "$wid" -eq "0" ]]; then
      $2
       else
      yabai -m window --focus "$wid"
       fi
    '';

    "skhd/space_focus_prev.sh".text = ''
      #!${bashbin}

      if [[ $(yabai -m query --spaces --display | ${jqbin} '.[0]."has-focus"') == "false" ]]; then yabai -m space --focus prev; fi
    '';

    "skhd/space_focus_next.sh".text = ''
      #!${bashbin}

      if [[ $(yabai -m query --spaces --display | ${jqbin} '.[-1]."has-focus"') == "false" ]]; then yabai -m space --focus next; fi
    '';

    "skhd/space_cycle_next.sh".text = ''
      #!${bashbin}

      info=$(yabai -m query --spaces --display)
      last=$(echo $info | jq '.[-1]."has-focus"')

      if [[ $last == "false" ]]; then
          yabai -m space --focus next
      else
          yabai -m space --focus $(echo $info | jq '.[0].index')
      fi
    '';

    "skhd/space_cycle_prev.sh".text = ''
      #!${bashbin}

      info=$(yabai -m query --spaces --display)
      first=$(echo $info | jq '.[0]."has-focus"')

      if [[ $first == "false" ]]; then
          yabai -m space --focus prev
      else
          yabai -m space --focus $(echo $info | jq '.[-1].index')
      fi
    '';

    "skhd/notify.sh".text = ''
      #!${bashbin}
      TITLE=$1
      MESSAGE=$2

      osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\""
    '';

    "skhd/display_cycle_next.sh".text = ''
      #!${bashbin}
      # focus next display with yabai in cycle.

      current_display_index=$(yabai -m query --displays --display | jq '."index"')
      total_displays=$(yabai -m query --displays | jq length)
      next_display_index=$((current_display_index + 1))

      if ((next_display_index > total_displays)); then
        next_display_index=1
      fi

      yabai -m display --focus "''${next_display_index}"
    '';

    "skhd/display_cycle_prev.sh".text = ''
      #!${bashbin}
      # focus previous display with yabai in cycle.

      current_display_index=$(yabai -m query --displays --display | jq '."index"')
      total_displays=$(yabai -m query --displays | jq length)
      prev_display_index=$((current_display_index - 1))

      if ((prev_display_index < 1)); then
        prev_display_index=$total_displays
      fi

      yabai -m display --focus "''${prev_display_index}"
    '';
  };
}
