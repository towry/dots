{
  pkgs,
  config,
  ...
}:
{
  home.packages = [
    # pkgs.rift
  ];

  xdg.configFile = {
    "rift/config.toml".text = ''
      # Rift configuration
      # See: https://github.com/acsandmann/rift/wiki/Config

      [settings]
      animate = true
      animation_duration = 0.2
      animation_fps = 100.0
      default_disable = false
      mouse_follows_focus = false
      mouse_hides_on_focus = false
      focus_follows_mouse = false
      hot_reload = true

      [settings.layout]
      mode = "traditional"

      [settings.layout.gaps]
      [settings.layout.gaps.outer]
      top = 2
      left = 2
      bottom = 2
      right = 2

      [settings.layout.gaps.inner]
      horizontal = 6
      vertical = 6

      [settings.ui]
      [settings.ui.menu_bar]
      enabled = true
      show_empty = false

      [settings.ui.stack_line]
      enabled = true
      thickness = 2.0
      horiz_placement = "top"
      vert_placement = "left"

      [settings.ui.mission_control]
      enabled = true
      fade_enabled = true
      fade_duration_ms = 200.0

      [settings.gestures]
      enabled = true
      invert_horizontal_swipe = false
      swipe_vertical_tolerance = 50.0
      skip_empty = true
      fingers = 3
      distance_pct = 0.3
      haptics_enabled = true

      [settings.window_snapping]
      drag_swap_fraction = 0.3

      [virtual_workspaces]
      enabled = true
      default_workspace_count = 9
      auto_assign_windows = true
      preserve_focus_per_workspace = true
      workspace_names = [
        "web",
        "code", 
        "terminal",
        "communication",
        "media",
        "files",
        "design",
        "virtual",
        "misc"
      ]
      default_workspace = 0

      app_rules = [
        # Web browsers
        { app_id = "com.apple.Safari", workspace = "web" },
        { app_id = "com.google.Chrome", workspace = "web" },
        { app_id = "com.microsoft.edgemac", workspace = "web" },
        
        # Code editors
        { app_id = "com.todesktop.Cursor", workspace = "code" },
        { app_id = "com.microsoft.VSCode", workspace = "code" },
        { app_id = "com.mitchellh.ghostty", workspace = "terminal" },
        
        # Communication
        { app_id = "com.hnc.Discord", workspace = "communication" },
        { app_id = "com.tinyspeck.slackmacgap", workspace = "communication" },
        { app_id = "com.tencent.xinWeChat", workspace = "communication", floating = true },
        { app_id = "com.tencent.WeWorkMac", workspace = "communication", floating = true },
        
        # Media
        { app_id = "com.apple.Music", workspace = "media" },
        { app_id = "com.apple.TV", workspace = "media" },
        
        # Files
        { app_id = "com.apple.finder", workspace = "files" },
        { app_id = "com.microsoft.excel", workspace = "files" },
        { app_id = "com.microsoft.word", workspace = "files" },
        { app_id = "com.microsoft.Powerpoint", workspace = "files" },
        
        # Design
        { app_id = "com.adobe.Photoshop", workspace = "design" },
        { app_id = "com.adobe.Illustrator", workspace = "design" },
        { app_id = "com.figma.Desktop", workspace = "design" },
        { app_id = "com.sketch.sketch", workspace = "design" },
        
        # System utilities - floating
        { app_id = "com.apple.systempreferences", floating = true },
        { app_id = "com.apple.SystemSettings", floating = true },
        { app_id = "com.apple.ActivityMonitor", floating = true },
        { app_id = "com.apple.Console", floating = true },
        { app_id = "com.apple.Spotlight", floating = true },
        { app_id = "com.surteesstudios.Bartender", floating = true },
        { app_id = "com.culturedcode.ThingsMac", floating = true },
        { app_id = "com.apple.calculator", floating = true },
        
        # Dialog windows - floating
        { ax_subrole = "AXSystemDialog", floating = true },
        { ax_subrole = "AXDialog", floating = true },
        { title_substring = "Preferences", floating = true },
        { title_substring = "Settings", floating = true }
      ]

      [modifier_combinations]
      alt = "Alt"
      alt_shift = "Alt + Shift"
      alt_ctrl = "Alt + Ctrl"
      alt_shift_ctrl = "Alt + Shift + Ctrl"
      cmd = "Meta"
      cmd_shift = "Meta + Shift"
      cmd_ctrl = "Meta + Ctrl"

      [keys]
      # Focus movement
      "cmd + H" = { move_focus = "left" }
      "cmd + J" = { move_focus = "down" }
      "cmd + K" = { move_focus = "up" }
      "cmd + L" = { move_focus = "right" }

      # Window movement
      "cmd_shift + H" = { move_node = "left" }
      "cmd_shift + J" = { move_node = "down" }
      "cmd_shift + K" = { move_node = "up" }
      "cmd_shift + L" = { move_node = "right" }

      # Workspace navigation (0-based indices)
      "cmd_ctrl + 1" = { switch_to_workspace = 0 }
      "cmd_ctrl + 2" = { switch_to_workspace = 1 }
      "cmd_ctrl + 3" = { switch_to_workspace = 2 }
      "cmd_ctrl + 4" = { switch_to_workspace = 3 }
      "cmd_ctrl + 5" = { switch_to_workspace = 4 }
      "cmd_ctrl + 6" = { switch_to_workspace = 5 }
      "cmd_ctrl + 7" = { switch_to_workspace = 6 }
      "cmd_ctrl + 8" = { switch_to_workspace = 7 }
      "cmd_ctrl + 9" = { switch_to_workspace = 8 }

      # "Alt + Tab" = "switch_to_last_workspace"
      "cmd_ctrl + P" = "prev_workspace"
      "cmd_ctrl + N" = "next_workspace"

      # Move window to workspace
      "Alt + Shift + 1" = { move_window_to_workspace = 0 }
      "Alt + Shift + 2" = { move_window_to_workspace = 1 }
      "Alt + Shift + 3" = { move_window_to_workspace = 2 }
      "Alt + Shift + 4" = { move_window_to_workspace = 3 }
      "Alt + Shift + 5" = { move_window_to_workspace = 4 }
      "Alt + Shift + 6" = { move_window_to_workspace = 5 }
      "Alt + Shift + 7" = { move_window_to_workspace = 6 }
      "Alt + Shift + 8" = { move_window_to_workspace = 7 }
      "Alt + Shift + 9" = { move_window_to_workspace = 8 }

      # Window management
      "Alt + F" = "toggle_window_floating"
      "Alt + Space" = "toggle_fullscreen"
      "Alt + Shift + Space" = "toggle_fullscreen_within_gaps"
      "Alt + S" = "stack_windows"
      "Alt + Shift + S" = "unstack_windows"
      "Alt + Shift + O" = "toggle_tile_orientation"
      "Alt + Ctrl + J" = { join_window = "down" }
      "Alt + Ctrl + K" = { join_window = "up" }
      "Alt + Ctrl + H" = { join_window = "left" }
      "Alt + Ctrl + L" = { join_window = "right" }

      # NOTE: unjoin_windows command exists in official config but may not work
      "Alt + Ctrl + E" = "unjoin_windows"

      # Window resizing
      "Alt + Equal" = "resize_window_grow"
      "Alt + Minus" = "resize_window_shrink"

      # Workspace management
      "Alt + Ctrl + W" = "create_workspace"
      "Alt + Z" = "toggle_space_activated"

      # Focus floating windows briefly
      "Alt + Ctrl + Space" = "toggle_focus_floating"

      # Debug and utility (commented out - may not be stable)
      # "Alt + Shift + D" = "debug"
      # "Alt + Ctrl + S" = "serialize"
    '';
  };
}
