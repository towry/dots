# Zellij Configuration Options Reference

Complete reference of all Zellij configuration options with examples.

## Core Configuration

### `theme`
Sets the color theme to use. The theme must be defined in the configuration's 'themes' section or loaded from the themes folder.

**Type:** String
**Default:** "default"

```kdl
theme "nord"
theme "dracula"
theme "custom_theme"
```

### `default_layout`
Specifies the name of the layout file to load when Zellij starts. The layout must exist in the layouts folder.

**Type:** String
**Default:** "default"

```kdl
default_layout "compact"
default_layout "development"
```

### `default_mode`
Determines the mode Zellij starts in.

**Type:** String
**Values:** "normal", "locked"
**Default:** "normal"

```kdl
default_mode "locked"
```

### `layout_dir`
Sets the directory where Zellij searches for layout files.

**Type:** String
**Default:** Subdirectory of config dir

```kdl
layout_dir "/path/to/my/layout_dir"
```

### `theme_dir`
Sets the directory where Zellij searches for theme files.

**Type:** String
**Default:** Subdirectory of config dir

```kdl
theme_dir "/path/to/my/theme_dir"
```

## Session Management

### `session_serialization`
Enables or disables Zellij session serialization.

**Type:** Boolean
**Default:** true

```kdl
session_serialization true
session_serialization false
```

### `pane_viewport_serialization`
When session serialization is enabled, allows serializing the pane viewport (visible terminal content).

**Type:** Boolean
**Default:** false

```kdl
pane_viewport_serialization true
```

### `scrollback_lines_to_serialize`
Number of scrollback lines to serialize when pane viewport serialization is enabled. Setting to 0 serializes all scrollback.

**Type:** Integer
**Default:** 1000

```kdl
scrollback_lines_to_serialize 0
scrollback_lines_to_serialize 500
```

## UI Configuration

### `ui` block
Contains UI-related settings.

#### `pane_frames`
Controls pane frame display settings.

##### `rounded_corners`
Determines whether pane frames should have rounded corners.

**Type:** Boolean
**Default:** true

```kdl
ui {
    pane_frames {
        rounded_corners true
    }
}
```

### Mouse Configuration

### `mouse_mode`
Sets handling of mouse events.

**Type:** Boolean
**Default:** true

```kdl
mouse_mode true
mouse_mode false
```

### `copy_on_select`
Automatically copy text when selecting.

**Type:** Boolean
**Default:** false

```kdl
copy_on_select true
```

## Environment Variables

### `env` block
Defines environment variables to be set for each terminal pane.

**Type:** Map of String to String/Integer

```kdl
env {
    RUST_BACKTRACE 1
    EDITOR "nvim"
    FOO "bar"
    PATH "/usr/local/bin:/usr/bin"
}
```

## Plugin Configuration

### `load_plugins` block
Plugins to load automatically when session starts.

**Type:** List of URLs or aliases

```kdl
load_plugins {
    https://example.com/plugin.wasm
    file:/path/to/local/plugin.wasm
    plugin-alias
}
```

### `plugins` block
Plugin aliases with optional configurations.

**Type:** Plugin configuration map

```kdl
plugins {
    tab-bar location="zellij:tab-bar"
    status-bar location="zellij:status-bar"
    custom-plugin location="file:/path/to/plugin.wasm" {
        option1 "value1"
        option2 42
    }
}
```

## Web Server Configuration

### `web_server`
Enable/disable web server startup.

**Type:** Boolean
**Default:** false

```kdl
web_server true
```

### `web_server_ip`
IP address for web server to listen on.

**Type:** String
**Default:** "127.0.0.1"

```kdl
web_server_ip "0.0.0.0"
```

### `web_server_port`
Port for web server to listen on.

**Type:** Integer
**Default:** 8082

```kdl
web_server_port 443
web_server_port 8083
```

### `web_server_cert`
Path to SSL certificate for HTTPS.

**Type:** String
**Default:** None

```kdl
web_server_cert "/path/to/cert.pem"
```

### `web_server_key`
Path to SSL private key for HTTPS.

**Type:** String
**Default:** None

```kdl
web_server_key "/path/to/key.pem"
```

### `enforce_https_on_localhost`
Enforce HTTPS certificate requirement even on localhost.

**Type:** Boolean
**Default:** false

```kdl
enforce_https_on_localhost true
```

## Web Client Configuration

### `web_client` block
Settings for browser-based terminal client.

#### `font`
Font for web client terminal.

**Type:** String
**Default:** "monospace"

```kdl
web_client {
  font "Iosevka Term"
}
```

#### `cursor_blink`
Enable cursor blinking.

**Type:** Boolean
**Default:** false

```kdl
web_client {
  cursor_blink true
}
```

#### `cursor_style`
Cursor style.

**Type:** String
**Values:** "block", "bar", "underline"
**Default:** "block"

```kdl
web_client {
  cursor_style "underline"
}
```

#### `cursor_inactive_style`
Inactive cursor style.

**Type:** String
**Values:** "outline", "block", "bar", "underline"
**Default:** "block"

```kdl
web_client {
  cursor_inactive_style "outline"
}
```

#### `mac_option_is_meta`
Treat Option key as Meta on macOS.

**Type:** Boolean
**Default:** true

```kdl
web_client {
  mac_option_is_meta false
}
```

#### `theme` block
Web client terminal theme (separate from Zellij theme).

**Type:** Color definitions in RGB format

```kdl
web_client {
  theme {
    background 10 20 30
    foreground 248 248 242
    // ... more colors
  }
}
```

## Multiplayer Configuration

### `multiplayer_user_colors`
Colors for users in multiplayer sessions.

**Type:** Map of player numbers to RGB values

```kdl
multiplayer_user_colors {
    player_1 255 0 255
    player_2 0 217 227
    // ... up to player_10
}
```

## Auto Layout Configuration

### `auto_layout`
Controls automatic pane arrangement.

**Type:** Boolean
**Default:** true

```kdl
auto_layout true
```

## Command Line Options

All configuration options can be overridden via command line:

```bash
# Override theme
zellij --theme nord

# Override layout
zellij --layout development

# Override config file
zellij --config /custom/path/config.kdl

# Override default mode
zellij --default-mode locked

# Set session name
zellij --session-name my-workspace

# Disable mouse
zellij --disable-mouse-mode

# Set custom shell
zellij --default-shell fish
```

## Configuration Validation

Use built-in validation:

```bash
# Check configuration syntax
zellij setup --check

# Dump default configuration
zellij setup --dump-config

# Dump default layout
zellij setup --dump-layout default
```

## File Locations

- **Config Directory:** `~/.config/zellij/`
- **Layouts Directory:** `~/.config/zellij/layouts/`
- **Themes Directory:** `~/.config/zellij/themes/`
- **Default Config:** `~/.config/zellij/config.kdl`

## Migration from YAML

Convert legacy YAML configuration:

```bash
# Convert config
zellij convert-config /path/to/config.yaml > /path/to/config.kdl

# Convert theme
zellij convert-theme /path/to/theme.yaml > /path/to/theme.kdl

# Convert layout
zellij convert-layout /path/to/layout.yaml > /path/to/layout.kdl
```