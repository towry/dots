---
name: zellij-config
description: "Comprehensive skill for managing Zellij terminal multiplexer configurations including setup, layouts, themes, keybindings, plugins, and web server configuration. Use this skill when users need to configure Zellij, create custom layouts, set up themes, manage keybindings, or configure web server access."
---

# Zellij Config

## Overview

This skill provides comprehensive Zellij terminal multiplexer configuration management. It enables users to set up Zellij from scratch, migrate configurations, create custom layouts and themes, manage keybindings, configure plugins, and set up web server access.

## Quick Start

Choose your configuration task:

1. **Setup Zellij** - Initialize configuration, create config directory, set basic settings
2. **Manage Layouts** - Create custom pane layouts, tab templates, swap layouts
3. **Configure Themes** - Set up custom themes, switch themes, convert theme formats
4. **Setup Keybindings** - Configure custom keybindings for different modes
5. **Plugin Management** - Load plugins, configure plugin aliases, set plugin options
6. **Web Server Setup** - Enable web access, configure SSL, set ports and IPs

## Setup Zellij

### Initialize Configuration Directory

Create Zellij configuration directory and dump default config:

```bash
mkdir -p ~/.config/zellij
zellij setup --dump-config > ~/.config/zellij/config.kdl
```

### Validate Configuration

Check existing configuration for errors:

```bash
zellij setup --check
```

### Clean Start

Start Zellij with clean configuration (ignores existing config):

```bash
zellij --clean
```

### Configuration File Location

Specify custom configuration file:

```bash
zellij --config /path/to/custom/config.kdl
# or via environment variable
export ZELLIJ_CONFIG_FILE=/path/to/custom/config.kdl
```

## Manage Layouts

### Create Default Layout

Generate a default layout template:

```bash
zellij setup --dump-layout default > ~/.config/zellij/layouts/default.kdl
```

### Create Custom Layout

Create a development layout with multiple panes:

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
    tab name="development" split_direction="vertical" {
        pane size="70%" {
            command "nvim"
            cwd "~/project"
        }
        pane split_direction="horizontal" {
            pane command="git" {
                args "status"
                cwd "~/project"
            }
            pane command="htop"
        }
    }
}
```

### Floating Layout Example

Layout with floating panes for different pane counts:

```kdl
layout {
    swap_floating_layout {
        floating_panes max_panes=1 {
            pane
        }
        floating_panes max_panes=2 {
            pane x=0
            pane x="50%"
        }
        floating_panes max_panes=3 {
            pane x=0 width="25%"
            pane x="25%" width="25%"
            pane x="50%"
        }
    }
}
```

### Use Custom Layout

Load a specific layout:

```bash
zellij --layout /path/to/custom-layout.kdl
# or place in ~/.config/zellij/layouts/ and use default
```

## Configure Themes

### Apply Built-in Theme

Set theme in configuration file:

```kdl
theme "default"
```

### Define Custom Theme (RGB)

Create a custom theme with RGB values:

```kdl
themes {
    custom_theme {
        fg 248 248 242
        bg 40 42 54
        black 0 0 0
        red 255 85 85
        green 80 250 123
        yellow 241 250 140
        blue 98 114 164
        magenta 255 121 198
        cyan 139 233 253
        white 255 255 255
        orange 255 184 108
    }
}
```

### Define Custom Theme (Hexadecimal)

Create a theme with hex color codes:

```kdl
themes {
    nord {
        fg "#D8DEE9"
        bg "#2E3440"
        black "#3B4252"
        red "#BF616A"
        green "#A3BE8C"
        yellow "#EBCB8B"
        blue "#81A1C1"
        magenta "#B48EAD"
        cyan "#88C0D0"
        white "#E5E9F0"
        orange "#D08770"
    }
}
```

### Switch Theme from Command Line

Temporarily use a theme:

```bash
zellij --theme custom_theme
```

### Convert Legacy Theme

Convert YAML theme to KDL format:

```bash
zellij convert-theme /path/to/old-theme.yaml > /path/to/new-theme.kdl
```

## Setup Keybindings

### Basic Keybinding Configuration

Configure keybindings for different modes:

```kdl
keybinds {
    normal {
        bind "Ctrl g" { SwitchToMode "locked"; }
        bind "Ctrl p" { SwitchToMode "pane"; }
        bind "Alt n" { NewPane; }
        bind "Alt h" "Alt Left" { MoveFocusOrTab "Left"; }
        bind "Ctrl Shift t" { NewTab; }
    }
    pane {
        bind "h" "Left" { MoveFocus "Left"; }
        bind "l" "Right" { MoveFocus "Right"; }
        bind "j" "Down" { MoveFocus "Down"; }
        bind "k" "Up" { MoveFocus "Up"; }
        bind "p" { SwitchFocus; }
        bind "Ctrl c" { CopySelection; }
    }
    locked {
        bind "Ctrl g" { SwitchToMode "normal"; }
    }
    shared {
        bind "Alt 1" { Run "git" "status"; }
        bind "Alt 2" { Run "git" "diff"; }
        bind "Alt 3" { Run "exa" "--color" "always"; }
    }
}
```

### Keybinding Syntax Examples

Different keybinding syntax patterns:

```kdl
bind "a"                    // individual character
bind "Ctrl a"                // with ctrl modifier
bind "Alt a"                 // with alt modifier
bind "Ctrl Alt a"            // multiple modifiers
bind "F8"                     // function key
bind "Left"                   // arrow key
```

## Plugin Management

### Load Plugins on Startup

Configure plugins to load automatically:

```kdl
load_plugins {
    https://example.com/my-plugin.wasm
    file:/path/to/my/plugin.kdl
    my-plugin-alias
}
```

### Configure Plugin Aliases

Set up common plugin aliases:

```kdl
plugins {
    tab-bar location="zellij:tab-bar"
    status-bar location="zellij:status-bar"
    strider location="zellij:strider"
    compact-bar location="zellij:compact-bar"
    session-manager location="zellij:session-manager"
    welcome-screen location="zellij:session-manager" {
        welcome_screen true
    }
    filepicker location="zellij:strider" {
        cwd "/"
    }
}
```

### Configure Plugin Options

Pass configuration to plugins:

```kdl
layout {
    pane {
        plugin location="file:/path/to/my/plugin.wasm" {
            some_key "some_value"
            another_key 1
        }
    }
}
```

### Launch Plugin with Configuration

Configure plugin via command line:

```bash
zellij action launch-or-focus-plugin --configuration "some_key=some_value,another_key=1"
```

## Web Server Setup

### Enable Web Server

Start web server automatically:

```kdl
web_server true
web_server_ip "0.0.0.0"
web_server_port 8082
```

### Configure SSL

Set up HTTPS with SSL certificates:

```kdl
web_server true
web_server_ip "0.0.0.0"
web_server_port 443
web_server_cert "/path/to/my/certs/localhost+3.pem"
web_server_key "/path/to/my/certs/localhost+3-key.pem"
enforce_https_on_localhost true
```

### Web Client Configuration

Configure browser-based terminal appearance:

```kdl
web_client {
  font "Iosevka Term"
  cursor_blink true
  cursor_style "block"
  cursor_inactive_style "outline"
  mac_option_is_meta false
  theme {
    background 10 20 30
    foreground 10 20 30
    black 10 20 30
    blue 10 20 30
    bright_black 10 20 30
    bright_blue 10 20 30
    bright_cyan 10 20 30
    bright_green 10 20 30
    bright_magenta 10 20 30
    bright_red 10 20 30
    bright_white 10 20 30
    bright_yellow 10 20 30
    cursor 10 20 30
    cursor_accent 10 20 30
    cyan 10 20 30
    green 10 20 30
    magenta 10 20 30
    red 10 20 30
    white 10 20 30
    yellow 10 20 30
    selection_background 10 20 30
    selection_foreground 10 20 30
    selection_inactive_background 10 20 30
  }
}
```

## Environment Variables

### Set Environment for Panes

Configure environment variables for all panes:

```kdl
env {
    RUST_BACKTRACE 1
    FOO "bar"
    EDITOR "nvim"
}
```

### Session Management

Configure session persistence and resurrection:

```kdl
session_serialization true
pane_viewport_serialization true
scrollback_lines_to_serialize 0
default_layout "compact"
default_mode "locked"
```

## Common Workflows

### Development Environment Setup

Create a comprehensive development layout:

```bash
# Create development layout
cat > ~/.config/zellij/layouts/dev.kdl << 'EOF'
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
    tab name="editor" cwd="~/project" focus=true {
        pane command="nvim" size="80%"
        pane size="20%" split_direction="vertical" {
            pane command="git" {
                args "status"
                size="50%"
            }
            pane command="htop"
        }
    }
    tab name="terminal" {
        pane command="bash"
    }
    tab name="monitoring" split_direction="horizontal" {
        pane command="htop"
        pane command="btop"
    }
}
EOF

# Use the layout
zellij --layout dev
```

### Multiplayer Session Setup

Configure colors for multiplayer sessions:

```kdl
multiplayer_user_colors {
    player_1 255 0 255
    player_2 0 217 227
    player_3 0
    player_4 255 230 0
    player_5 0 229 229
    player_6 0
    player_7 255 53 94
    player_8 0
    player_9 0
    player_10 0
}
```

## Configuration Validation

### Check Configuration

Validate configuration file syntax:

```bash
zellij setup --check
```

### Test Configuration

Test new configuration without affecting existing session:

```bash
zellij --config /path/to/test-config.kdl --session-name test-session
```

## Resources

### scripts/
Executable scripts for Zellij configuration management:

- `setup_zellij.py` - Automates initial Zellij setup
- `create_layout.py` - Generates custom layouts from templates
- `convert_themes.py` - Converts legacy theme formats to KDL
- `validate_config.py` - Validates Zellij configuration syntax
- `backup_config.py` - Creates configuration backups

### references/
Comprehensive Zellij configuration documentation:

- `configuration_options.md` - Complete reference of all Zellij options
- `layout_examples.md` - Collection of layout templates
- `theme_examples.md` - Custom theme examples and guidelines
- `keybinding_reference.md` - Complete keybinding syntax and actions
- `plugin_api.md` - Plugin development and configuration guide

### assets/
Configuration templates and example files:

- `config_templates/` - Starter configuration files for different use cases
- `layout_templates/` - Common layout templates (development, monitoring, etc.)
- `theme_templates/` - Custom theme files (nord, dracula, etc.)
- `plugin_examples/` - Example plugin configurations
