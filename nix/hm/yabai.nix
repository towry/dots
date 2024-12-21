{
  pkgs,
  config,
  ...
}: {
  home.packages = [
    pkgs.yabai
  ];
  xdg.configFile = let
    bash = "${pkgs.bash}/bin/bash";
    # jqbin = "${pkgs.jq}/bin/jq";
    yabaiDir = "${config.xdg.configHome}/yabai";
    yabai = "${pkgs.yabai}/bin/yabai";
  in {
    "yabai/yabairc".text = ''
      #!${pkgs.bash}/bin/bash

      # the scripting-addition must be loaded manually if
      # you are running yabai on macOS Big Sur. Uncomment
      # the following line to have the injection performed
      # when the config is executed during startup.
      #
      # for this to work you must configure sudo such that
      # it will be able to run the command without password
      #
      # see this wiki page for information:
      #  - https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(from-HEAD)#configure-scripting-addition
      # See the config doc:
      #   - https://github.com/koekeishiya/yabai/blob/master/doc/yabai.asciidoc
      #
      # --------------------------------------------------------
      ${yabai} -m signal --add event=dock_did_restart action="sudo ${yabai} --load-sa"
      sudo ${yabai} --load-sa

      # yabai -m signal --list
      # focus window after active space changes
      # keeps calling twice.
      ${yabai} -m signal --add event=space_changed action="${bash} ${yabaiDir}/focus-window.sh"
      # focus window after active display changes
      ${yabai} -m signal --add event=display_changed action="${bash} ${yabaiDir}/focus-window.sh"

      # Unload the macOS WindowManager process
      launchctl unload -F /System/Library/LaunchAgents/com.apple.WindowManager.plist > /dev/null 2>&1 &

      # -- mouse --

      # yabai -m config focus_follows_mouse autofocus
      # -- off autoraise autofocus
      ${yabai} -m config focus_follows_mouse off
      # yabai -m config mouse_modifier fn
      # yabai -m config mouse_action1 resize
      # yabai -m config mouse_action2 move

      # -- window --
      ${yabai} -m config window_placement second_child
      ${yabai} -m config window_shadow on
      ${yabai} -m config insert_feedback_color 0xaad75f5f
      ${yabai} -m config split_ratio 0.50
      ${yabai} -m config auto_balance on
      ${yabai} -m config window_opacity off
      # yabai -m config window_opacity_duration 0.0
      # yabai -m config active_window_opacity 1.0
      # yabai -m config normal_window_opacity 1.0

      # -- space --

      ${yabai} -m config layout stack
      # ${yabai} -m config --space 1 layout stack
      # ${yabai} -m config --space 2 layout bsp
      # ${yabai} -m config --space 3 layout bsp
      ${yabai} -m config top_padding 4
      ${yabai} -m config bottom_padding 4
      ${yabai} -m config left_padding 4
      ${yabai} -m config right_padding 4
      # Will create extra space at top for external bar.
      ${yabai} -m config external_bar all:0:0
      ${yabai} -m config window_gap 6
      ${yabai} -m space 1 --label web
      ${yabai} -m space 2 --label code


      #-- rules --
      ## see: https://github.com/koekeishiya/yabai/issues/1929
      ${yabai} -m rule --add app=".*" sub-layer=normal
      ${yabai} -m rule --add app="^(Safari|Firefox|Google Chrome)$" space=web role=AXWindow subrole=AXStandardWindow
      ${yabai} -m rule --add app="^(Ghostty|Cursor)$" space=code role=AXWindow subrole=AXStandardWindow
      ${yabai} -m rule --add app="(System Preferences|系统偏好设置|系统设置|微信|wechat|短信|\.dmg)$" manage=off sub-layer=normal
      ${yabai} -m rule --add app="(微信|钉钉|Wechat|企业微信|Telegram|Numi|MenubarX)" manage=off sub-layer=normal
      ${yabai} -m rule --add app="(腾讯会议|快速会议|会议|Capacities|数码测色计|富途牛牛)" manage=off sub-layer=normal
      ${yabai} -m rule --add app="^\s*$" manage=off sub-layer=normal
      ${yabai} -m rule --add app="Things" manage=off sub-layer=normal
      ${yabai} -m rule --add app="QQ音乐" manage=off sub-layer=normal
      ${yabai} -m rule --add app="(Finder|访达|DevTools|模拟器|Kap|Bartender|TradingView)" manage=off sub-layer=normal
      ${yabai} -m rule --apply

      ${yabai} -m signal --add event=window_destroyed active=yes action="yabai -m query --windows --window &> /dev/null || yabai -m window --focus mouse &> /dev/null || yabai -m window --focus \$(yabai -m query --windows --space | jq .[0].id) &> /dev/null"
      ${yabai} -m signal --add event=window_minimized active=yes action="if \$(yabai -m query --windows --window \$YABAI_WINDOW_ID | jq -r '.\"is-floating\"'); then yabai -m query --windows --window &> /dev/null || yabai -m window --focus mouse &> /dev/null || yabai -m window --focus \$(yabai -m query --windows --space | jq .[0].id) &> /dev/null; fi"

      # stackline specific tweaks
      # yabai -m signal --add event=window_created action="~/.config/yabai/adjust-padding-for-stacked-windows.sh"
      # yabai -m signal --add event=window_destroyed action="~/.config/yabai/adjust-padding-for-stacked-windows.sh"
      # yabai -m signal --add event=window_focused action="sketchybar --trigger window_focus"
      # yabai -m signal --add event=window_created action="sketchybar --trigger windows_on_spaces"
      # yabai -m signal --add event=window_title_changed action="sketchybar -m --trigger title_change"
      # yabai -m signal --add event=window_destroyed action="sketchybar --trigger windows_on_spaces"
      # yabai -m signal --add label="flash_window_focus" event="window_focused" action="yabai -m window \$YABAI_WINDOW_ID --opacity 0.1 && sleep $(yabai -m config window_opacity_duration) && yabai -m window \$YABAI_WINDOW_ID --opacity 0.0"

      echo "yabai configuration loaded.."
    '';
  };
}
