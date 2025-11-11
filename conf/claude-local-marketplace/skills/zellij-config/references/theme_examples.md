# Zellij Theme Examples

Collection of custom themes and theme creation guidelines.

## Built-in Themes

### Default Theme
Standard light theme:

```kdl
theme "default"
```

### Nord Theme
Popular dark theme based on Nordic colors:

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

### Dracula Theme
Popular dark theme:

```kdl
themes {
    dracula {
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

## Custom Themes

### Custom RGB Theme
Theme using RGB color values:

```kdl
themes {
    my_custom_theme {
        fg 200 200 200
        bg 30 30 30
        black 40 40 40
        red 255 100 100
        green 100 255 100
        yellow 255 255 100
        blue 100 100 255
        magenta 255 100 255
        cyan 100 255 255
        white 255 255 255
        orange 255 200 100
    }
}
```

### Custom Hex Theme
Theme using hexadecimal color codes:

```kdl
themes {
    cyberpunk {
        fg "#00ff00"
        bg "#0a0a0a"
        black "#1a1a1a"
        red "#ff0000"
        green "#00ff00"
        yellow "#ffff00"
        blue "#0080ff"
        magenta "#ff00ff"
        cyan "#00ffff"
        white "#ffffff"
        orange "#ff8000"
    }
}
```

### Solarized Dark
Classic solarized color scheme:

```kdl
themes {
    solarized_dark {
        fg "#839496"
        bg "#002b36"
        black "#073642"
        red "#dc322f"
        green "#859900"
        yellow "#b58900"
        blue "#268bd2"
        magenta "#d33682"
        cyan "#2aa198"
        white "#eee8d5"
        orange "#cb4b16"
    }
}
```

### Gruvbox Dark
Popular dark theme for developers:

```kdl
themes {
    gruvbox_dark {
        fg "#ebdbb2"
        bg "#282828"
        black "#1d2021"
        red "#cc241d"
        green "#98971a"
        yellow "#d79921"
        blue "#83a598"
        magenta "#d3869b"
        cyan "#8ec07c"
        white "#ebdbb2"
        orange "#fe8019"
    }
}
```

### Monokai
Clean, minimal dark theme:

```kdl
themes {
    monokai {
        fg "#ffffff"
        bg "#272822"
        black "#272822"
        red "#ff5555"
        green "#50fa7b"
        yellow "#f1fa8c"
        blue "#8be9fd"
        magenta "#bd93f9"
        cyan "#8fa8c0"
        white "#f8f8f2"
        orange "#ff6b6b"
    }
}
```

### Tokyo Night
Modern dark theme with blue tones:

```kdl
themes {
    tokyo_night {
        fg "#c0caf5"
        bg "#1a1b26"
        black "#393939"
        red "#f7768e"
        green "#9ece6a"
        yellow "#e0af68"
        blue "#7aa2f7"
        magenta "#bb9af7"
        cyan "#89dceb"
        white "#d9d7d8"
        orange "#e06c75"
    }
}
```

## Theme Component Colors

### Ribbon UI Colors
Some themes support detailed ribbon component colors:

```kdl
themes {
    detailed_theme {
        ribbon_unselected {
            base 10 10 10
            background 50 50 50
            emphasis_0 200 200 200
            emphasis_1 220 220 220
            emphasis_2 240 240 240
            emphasis_3 255 255 255
        }
        ribbon_selected {
            base 20 20 20
            background 60 60 60
            emphasis_0 210 210 210
            emphasis_1 230 230 230
            emphasis_2 250 250 250
            emphasis_3 255 255 255
        }
    }
}
```

### Multiplayer Colors
Configure colors for multiplayer sessions:

```kdl
multiplayer_user_colors {
    player_1 255 0 255    // Magenta
    player_2 0 255 255      // Blue
    player_3 0 0 0          // Black
    player_4 255 255 0      // Red
    player_5 0 255 0          // Black
    player_6 255 255 255    // White
    player_7 255 0 255      // Magenta
    player_8 0 255 0          // Black
    player_9 0 200 0          // Green
    player_10 0 0 255          // Blue
}
```

## Theme Creation Guidelines

### Color Format Options

#### RGB Format
Use three space-separated values (0-255):

```kdl
color_name 200 150 100  // R=200, G=150, B=100
```

#### Hexadecimal Format
Use standard hex color codes with # prefix:

```kdl
color_name "#ff6b6b"  // Orange-red
```

#### Mixed Format
You can mix formats in the same theme:

```kdl
themes {
    mixed_theme {
        fg "#ffffff"           // Hex for foreground
        bg 40 42 54          // RGB for background
        red "#cc241d"           // Hex for accent
        green 80 250 123        // RGB for success
        yellow 241 250 140      // RGB for warning
    }
}
```

### Theme Design Best Practices

1. **Contrast is Key**
   - Ensure text remains readable against background
   - Test with different terminal profiles
   - Consider accessibility (WCAG contrast ratios)

2. **Consistent Color Palette**
   - Limit to 8-12 colors for consistency
   - Use semantic naming (success, warning, error, etc.)
   - Maintain harmony across color choices

3. **Test Across Applications**
   - Verify colors work in nvim, vim, tmux, etc.
   - Test with syntax highlighting themes
   - Check compatibility with common tools

4. **Consider Environment**
   - Account for different lighting conditions
   - Support both dark and light variants
   - Provide high contrast options

### Common Color Values

#### Standard Colors
```kdl
// Pure colors
black   0 0 0       // #000000
white   255 255 255 // #ffffff
red     255 0 0       // #ff0000
green   0 255 0       // #00ff00
blue    0 0 255       // #0000ff
yellow  255 255 0   // #ffff00
magenta 255 0 255   // #ff00ff
cyan    0 255 255   // #00ffff
```

#### Gray Scale
```kdl
// Gray variations
gray_25  25  25  25
gray_50  50  50  50
gray_75  75  75  75
gray_100 100 100 100
gray_125 125 125 125
gray_150 150 150 150
gray_175 175 175 175
gray_200 200 200 200
```

#### Popular Theme Colors
```kdl
// Nord theme palette
nord_frost  "#D8DEE9"  // Light blue
nord_snow   "#E5E9F0"  // Pure white
nord_polar  "#2E3440"  // Dark blue-gray
nord_night  "#3B4252"  // Dark gray-blue
nord_aurora "#88C0D0"  // Cyan

// Dracula theme palette
dracula_bg     "#282a36"  // Dark purple
dracula_fg     "#f8f8f2"  // Light gray
dracula_pink   "#ff79c6"  // Bright pink
dracula_cyan   "#8be9fd"  // Bright cyan
dracula_green  "#50fa7b"  // Bright green
dracula_orange "#ffb86c"  // Bright orange
```

## Theme Testing

### Validate Theme Colors
Check theme works properly:

```bash
# Test theme in new session
zellij --theme your_theme --session-name test-theme

# Keep session open for inspection
```

### Preview Multiple Themes
Quickly switch between themes for testing:

```bash
# Test multiple themes
for theme in nord dracula tokyo_night; do
    zellij --theme "$theme" --session-name "test-$theme"
    echo "Theme $theme ready for testing"
done
```

### Create Theme Variants
Generate light/dark variants of base theme:

```kdl
themes {
    my_theme_dark {
        fg "#e0e0e0"
        bg "#000000"
        // ... other colors
    }
    my_theme_light {
        fg "#000000"
        bg "#ffffff"
        // ... other colors (inverted/light versions)
    }
}
```

## Integration with Editors

### Vim Integration
Theme compatibility with vim color schemes:

```kdl
themes {
    vim_compatible {
        // Use colors that match popular vim themes
        fg "#abb2bf"           // Similar to 'morning' vim theme
        bg "#1a1b26"           // Similar to 'morning' vim theme background
        // Match other colors accordingly
    }
}
```

### Neovim Integration
Modern editor theme compatibility:

```kdl
themes {
    nvim_compatible {
        fg "#b0e1e6"           // Similar to 'tokyonight' nvim theme
        bg "#16161d"           // Similar to 'tokyonight' nvim theme background
        // Match other accent colors
    }
}
```