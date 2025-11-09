#!/usr/bin/env python3
"""
Zellij Theme Converter - Convert themes between formats and create custom themes

Usage:
    convert_themes.py [COMMAND] [OPTIONS]

Commands:
    create     - Create a new custom theme
    convert    - Convert legacy YAML theme to KDL
    list       - List available theme templates

Examples:
    convert_themes.py create --name mytheme --rgb
    convert_themes.py convert /path/to/theme.yaml
    convert_themes.py list
"""

import argparse
import json
import sys
from pathlib import Path


THEME_TEMPLATES = {
    "nord": {
        "fg": "#D8DEE9",
        "bg": "#2E3440",
        "black": "#3B4252",
        "red": "#BF616A",
        "green": "#A3BE8C",
        "yellow": "#EBCB8B",
        "blue": "#81A1C1",
        "magenta": "#B48EAD",
        "cyan": "#88C0D0",
        "white": "#E5E9F0",
        "orange": "#D08770"
    },
    "dracula": {
        "fg": "248 248 242",
        "bg": "40 42 54",
        "black": "0 0 0",
        "red": "255 85 85",
        "green": "80 250 123",
        "yellow": "241 250 140",
        "blue": "98 114 164",
        "magenta": "255 121 198",
        "cyan": "139 233 253",
        "white": "255 255 255",
        "orange": "255 184 108"
    },
    "gruvbox-dark": {
        "fg": "#ebdbb2",
        "bg": "#282828",
        "black": "#1d2021",
        "red": "#cc241d",
        "green": "#98971a",
        "yellow": "#d79921",
        "blue": "#83a598",
        "magenta": "#d3869b",
        "cyan": "#8ec07c",
        "white": "#ebdbb2",
        "orange": "#fe8019"
    }
}


def create_theme(name, use_rgb=True):
    """Create a new custom theme interactively."""
    theme_data = {}

    print(f"🎨 Creating theme: {name}")
    print("Enter theme colors (press Enter for defaults):")

    colors = ["fg", "bg", "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white", "orange"]

    for color in colors:
        if use_rgb:
            print(f"{color} (RGB format: r g b):")
            value = input(f"  {color}: ").strip()
            if value:
                # Parse RGB values
                parts = value.split()
                if len(parts) == 3 and all(p.isdigit() for p in parts):
                    theme_data[color] = f"{parts[0]} {parts[1]} {parts[2]}"
                else:
                    print(f"  Using default {color}")
        else:
            print(f"{color} (hex format: #RRGGBB):")
            value = input(f"  {color}: ").strip()
            if value:
                theme_data[color] = value

    return theme_data


def generate_kdl_theme(name, theme_data, output_path):
    """Generate KDL format theme file."""
    content = f"themes {{\n    {name} {{\n"

    for color, value in theme_data.items():
        content += f'        {color} {value}\n'

    content += "    }}\n}}\n"

    try:
        with open(output_path, 'w') as f:
            f.write(content)
        return True
    except Exception as e:
        print(f"❌ Error writing theme file: {e}")
        return False


def convert_yaml_to_kdl(yaml_path):
    """Convert legacy YAML theme to KDL format."""
    try:
        import yaml
        with open(yaml_path, 'r') as f:
            theme_data = yaml.safe_load(f)

        if not theme_data:
            print("❌ No theme data found in YAML file")
            return False

        # Extract theme name from filename
        theme_name = Path(yaml_path).stem
        output_path = Path(yaml_path).with_suffix('.kdl')

        return generate_kdl_theme(theme_name, theme_data, output_path)
    except ImportError:
        print("❌ PyYAML not installed. Install with: pip install pyyaml")
        return False
    except Exception as e:
        print(f"❌ Error converting YAML theme: {e}")
        return False


def list_templates():
    """List available theme templates."""
    print("📋 Available theme templates:")
    for name, colors in THEME_TEMPLATES.items():
        print(f"  {name}:")
        if isinstance(colors["fg"], str):
            print(f"    Type: Hexadecimal")
            print(f"    Preview: FG={colors['fg']}, BG={colors['bg']}")
        else:
            print(f"    Type: RGB")
            print(f"    Preview: FG=({colors['fg']}), BG=({colors['bg']})")


def main():
    parser = argparse.ArgumentParser(description="Manage Zellij themes")
    subparsers = parser.add_subparsers(dest='command', help='Available commands')

    # Create command
    create_parser = subparsers.add_parser('create', help='Create new custom theme')
    create_parser.add_argument('--name', required=True, help='Theme name')
    create_parser.add_argument('--hex', action='store_true', help='Use hexadecimal color format (default: RGB)')
    create_parser.add_argument('--output', help='Output file path (default: ~/.config/zellij/themes/name.kdl)')

    # Convert command
    convert_parser = subparsers.add_parser('convert', help='Convert YAML theme to KDL')
    convert_parser.add_argument('yaml_path', help='Path to YAML theme file')

    # List command
    list_parser = subparsers.add_parser('list', help='List theme templates')

    args = parser.parse_args()

    if args.command == 'create':
        theme_data = create_theme(args.name, not args.hex)
        output_path = args.output or Path.home() / ".config" / "zellij" / "themes" / f"{args.name}.kdl"

        if generate_kdl_theme(args.name, theme_data, output_path):
            print(f"✅ Theme created: {output_path}")
        else:
            sys.exit(1)

    elif args.command == 'convert':
        if convert_yaml_to_kdl(args.yaml_path):
            print("✅ Theme conversion complete")
        else:
            sys.exit(1)

    elif args.command == 'list':
        list_templates()

    else:
        parser.print_help()


if __name__ == "__main__":
    main()