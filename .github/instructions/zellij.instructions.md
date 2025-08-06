---
applyTo: '**'
description: Comprehensive guide for configuring Zellij terminal multiplexer
---

# Zellij Configuration Guide

Based on the official Zellij examples from: https://github.com/zellij-org/zellij/tree/main/example

## Overview

Zellij is a terminal workspace manager written in Rust. It uses KDL (KubeDoc Language) format for configuration files, which provides a clean and readable syntax for complex configurations.

## Configuration File Structure

### 1. Main Configuration File Location

- **Default location**: `~/.config/zellij/config.kdl`
- **Alternative**: Use `--config` flag to specify custom location

### 2. Key Configuration Sections

1. **Keybinds**: Define custom key mappings and modal behaviors
2. **Plugins**: Configure built-in and external plugins
3. **Themes**: Define color schemes
4. **Layouts**: Set up predefined pane arrangements
5. **General Settings**: Various behavioral options

## Keybinds Configuration

### Modal System

Zellij operates with different modes, each having its own keybindings:

- `normal` - Default mode for general operations
- `locked` - Prevents accidental key presses
- `resize` - For resizing panes
- `pane` - Pane management operations
- `move` - Moving panes around
- `tab` - Tab management
- `scroll` - Scrolling through pane history
- `search` - Searching within scrollback
- `session` - Session management
- `tmux` - Tmux-compatible bindings

### Example Keybind Configuration

```kdl
keybinds {
    normal {
        // Uncomment if using copy_on_select=false
        // bind "Alt c" { Copy; }
    }
    locked {
        bind "Ctrl g" { SwitchToMode "Normal"; }
    }
    resize {
        bind "Ctrl n" { SwitchToMode "Normal"; }
        bind "h" "Left" { Resize "Left"; }
        bind "j" "Down" { Resize "Down"; }
        bind "k" "Up" { Resize "Up"; }
        bind "l" "Right" { Resize "Right"; }
        bind "=" "+" { Resize "Increase"; }
        bind "-" { Resize "Decrease"; }
    }
    pane {
        bind "Ctrl p" { SwitchToMode "Normal"; }
        bind "h" "Left" { MoveFocus "Left"; }
        bind "l" "Right" { MoveFocus "Right"; }
        bind "j" "Down" { MoveFocus "Down"; }
        bind "k" "Up" { MoveFocus "Up"; }
        bind "n" { NewPane; SwitchToMode "Normal"; }
        bind "d" { NewPane "Down"; SwitchToMode "Normal"; }
        bind "r" { NewPane "Right"; SwitchToMode "Normal"; }
        bind "x" { CloseFocus; SwitchToMode "Normal"; }
        bind "f" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
        bind "c" { SwitchToMode "RenamePane"; PaneNameInput 0; }
    }
    shared_except "locked" {
        bind "Ctrl g" { SwitchToMode "Locked"; }
        bind "Ctrl q" { Quit; }
        bind "Alt n" { NewPane; }
        bind "Alt h" "Alt Left" { MoveFocusOrTab "Left"; }
        bind "Alt l" "Alt Right" { MoveFocusOrTab "Right"; }
    }
}
```

### Special Keybind Notes

- Use double quotes for newline characters: `"Ctrl \"\n\""` instead of `'Ctrl \'\n\'`
- `shared_except` defines bindings available in all modes except specified ones
- Multiple keys can be bound to the same action: `bind "h" "Left" { MoveFocus "Left"; }`

## Plugins Configuration

### Built-in Plugins

```kdl
plugins {
    tab-bar location="zellij:tab-bar"
    status-bar location="zellij:status-bar"
    strider location="zellij:strider"           // File manager
    compact-bar location="zellij:compact-bar"
    session-manager location="zellij:session-manager"
    welcome-screen location="zellij:session-manager" {
        welcome_screen true
    }
    filepicker location="zellij:strider" {
        cwd "/"
    }
    configuration location="zellij:configuration"
    plugin-manager location="zellij:plugin-manager"
}
```

### Loading Background Plugins

```kdl
load_plugins {
    // Load plugins automatically when session starts
    // "file:/path/to/my-plugin.wasm"
    // "https://example.com/my-plugin.wasm"
}
```

## Themes Configuration

### Defining Custom Themes

```kdl
themes {
    // RGB format theme
    gruvbox-light {
        fg 60 56 54
        bg 251 82 75
        black 40 40 40
        red 205 75 69
        green 152 151 26
        yellow 215 153 33
        blue 69 133 136
        magenta 177 98 134
        cyan 104 157 106
        white 213 196 161
        orange 214 93 14
    }

    // HEX format theme
    gruvbox-dark {
        fg "#D5C4A1"
        bg "#282828"
        black "#3C3836"
        red "#CC241D"
        green "#98971A"
        yellow "#D79921"
        blue "#3C8588"
        magenta "#B16286"
        cyan "#689D6A"
        white "#FBF1C7"
        orange "#D65D0E"
    }
}

// Activate a theme
theme "gruvbox-dark"
```

## Layouts Configuration

### Simple Layout Example

```kdl
layout {
    default_tab_template {
        children
    }
    tab split_direction="Vertical" {
        pane split_direction="Vertical" {
            pane size="50%" split_direction="Horizontal" {
                pane size="50%"
                pane command="htop" size="50%"
            }
            pane command="htop" size="50%"
        }
    }
}
```

### Complex Multi-Tab Layout

```kdl
layout {
    default_tab_template {
        pane size=1 borderless=true {
            plugin location="zellij:tab-bar"
        }
        children
        pane size=2 borderless=true {
            plugin location="zellij:status-bar"
        }
    }
    tab split_direction="Vertical" {
        pane split_direction="Vertical" {
            pane size="50%"
            pane size="50%"
        }
    }
    tab split_direction="Vertical" {
        pane split_direction="Vertical" {
            pane size="20%" {
                plugin location="zellij:strider"
            }
            pane size="80%" split_direction="Horizontal" {
                pane size="50%"
                pane size="50%"
            }
        }
    }
}
```

## General Settings

### Essential Configuration Options

```kdl
// Shell configuration
default_shell "fish"                    // Default: $SHELL
default_cwd "/path/to/directory"        // Override working directory

// UI settings
simplified_ui true                      // Use ASCII instead of unicode
pane_frames true                        // Show borders around panes
mouse_mode false                        // Disable mouse interactions

// Session behavior
on_force_close "quit"                   // Options: "detach" (default), "quit"
session_serialization false            // Save sessions for resurrection
serialize_pane_viewport true           // Include scrollback in sessions
scrollback_lines_to_serialize 10000    // Lines to save with viewport

// Layout and theme paths
layout_dir "/path/to/my/layout_dir"
theme_dir "/path/to/my/theme_dir"
default_layout "my-custom-layout"       // Default: "default"
default_mode "locked"                   // Default: "normal"

// Performance and buffer settings
scroll_buffer_size 10000                // Scrollback buffer size
auto_layout true                        // Use predefined layouts when possible
stacked_resize false                    // Don't stack panes when resizing

// Copy/paste configuration
copy_command "pbcopy"                   // macOS clipboard command
// copy_command "xclip -selection clipboard"  // Linux X11
// copy_command "wl-copy"                      // Linux Wayland
copy_clipboard "primary"                // Options: "system", "primary"
copy_on_select false                    // Auto-copy on selection
scrollback_editor "/usr/bin/vim"        // Editor for scrollback editing

// Web server settings (optional)
web_server true                         // Enable web interface
web_server_port 8082                    // Default port
web_server_ip "127.0.0.1"              // Bind address
web_sharing "off"                       // Options: "on", "off", "disabled"
```

### Advanced Features

```kdl
// Mirror sessions for shared viewing
mirror_session true

// Enhanced terminal features
styled_underlines false                 // For unsupported terminals
support_kitty_keyboard_protocol false   // Kitty protocol support
disable_session_metadata true           // Don't write session metadata

// Advanced mouse features
advanced_mouse_actions false            // Hover effects and grouping

// Command discovery hook for session resurrection
post_command_discovery_hook "echo $RESURRECT_COMMAND | sed 's/wrapper//g'"
```

### Web Client Configuration

```kdl
web_client {
    font "monospace"
}
```

## Directory Structure

### Recommended Layout

```
~/.config/zellij/
├── config.kdl              # Main configuration
├── layouts/                # Custom layouts
│   ├── dev.kdl
│   ├── monitoring.kdl
│   └── writing.kdl
└── themes/                 # Custom themes
    ├── my-theme.kdl
    └── dark-mode.kdl
```

## Best Practices

### 1. Configuration Management

- **Version control**: Keep your config in dotfiles repository
- **Modular approach**: Separate layouts and themes into individual files
- **Testing**: Use `zellij --layout <layout-file>` to test layouts
- **Validation**: Check configuration syntax before applying

### 2. Keybinding Design

- **Consistency**: Use vim-like navigation (h/j/k/l)
- **Modal efficiency**: Group related actions in appropriate modes
- **Conflict avoidance**: Be careful not to override essential terminal shortcuts
- **Documentation**: Comment complex keybindings

### 3. Layout Organization

- **Purpose-specific**: Create layouts for different workflows (development, monitoring, etc.)
- **Size ratios**: Use percentage-based sizing for responsive layouts
- **Command integration**: Pre-load commonly used commands in panes
- **Plugin placement**: Position plugins (file manager, status bar) strategically

### 4. Theme Management

- **Accessibility**: Ensure sufficient contrast in color schemes
- **Consistency**: Align with your terminal emulator theme
- **Environment adaptation**: Consider different themes for different environments

### 5. Performance Optimization

- **Buffer limits**: Set appropriate scroll buffer sizes
- **Plugin selection**: Only load necessary plugins
- **Session management**: Configure serialization based on usage patterns

## Migration Tips

### From tmux

- Use `tmux` mode for familiar keybindings during transition
- Map common tmux commands to Zellij equivalents
- Gradually adopt Zellij-specific features

### From Screen

- Focus on session management features
- Configure appropriate detach behavior
- Set up layouts to replace screen's window arrangements

## Troubleshooting

### Common Issues

1. **Keybinding conflicts**: Check terminal emulator shortcuts
2. **Theme not loading**: Verify theme name matches configuration
3. **Layout errors**: Validate KDL syntax and file paths
4. **Plugin failures**: Ensure plugin locations are correct
5. **Performance issues**: Reduce scroll buffer size or plugin count

### Debug Commands

```bash
# Check configuration validity
zellij setup --check

# Generate default config
zellij setup --generate-config

# List available layouts/themes
zellij list-layouts
zellij list-themes

# Start with specific configuration
zellij --config /path/to/config.kdl
```

## Resources

- **Official Repository**: https://github.com/zellij-org/zellij
- **Example Configurations**: https://github.com/zellij-org/zellij/tree/main/example
- **Plugin Development**: https://zellij.dev/documentation/plugins
- **Community Themes**: Check GitHub for community-contributed themes and layouts
