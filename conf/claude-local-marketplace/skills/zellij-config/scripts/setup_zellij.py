#!/usr/bin/env python3
"""
Zellij Setup Script - Automates initial Zellij configuration setup

Usage:
    setup_zellij.py [--theme THEME] [--layout LAYOUT] [--keybindings] [--clean]

Examples:
    setup_zellij.py --theme nord --layout dev
    setup_zellij.py --clean
    setup_zellij.py --keybindings
"""

import argparse
import os
import sys
from pathlib import Path


def create_config_directory():
    """Create Zellij configuration directory if it doesn't exist."""
    config_dir = Path.home() / ".config" / "zellij"
    config_dir.mkdir(parents=True, exist_ok=True)
    return config_dir


def dump_default_config(config_path):
    """Dump default Zellij configuration to file."""
    import subprocess
    try:
        result = subprocess.run(
            ["zellij", "setup", "--dump-config"],
            capture_output=True,
            text=True,
            check=True
        )
        if result.returncode == 0:
            with open(config_path, 'w') as f:
                f.write(result.stdout)
            print(f"✅ Default config written to {config_path}")
            return True
        else:
            print(f"❌ Failed to dump default config: {result.stderr}")
            return False
    except FileNotFoundError:
        print("❌ zellij command not found. Please install Zellij first.")
        return False
    except Exception as e:
        print(f"❌ Error running zellij: {e}")
        return False


def create_layout_directory(config_dir):
    """Create layouts directory within config directory."""
    layouts_dir = config_dir / "layouts"
    layouts_dir.mkdir(exist_ok=True)
    return layouts_dir


def setup_theme(theme_name, config_path):
    """Set theme in configuration file."""
    if not theme_name:
        return True

    try:
        with open(config_path, 'r') as f:
            content = f.read()

        # Check if theme block exists, if not add it
        if 'theme "' not in content:
            content += '\ntheme "' + theme_name + '"\n'
        else:
            # Replace existing theme
            import re
            content = re.sub(r'theme\s+"[^"]*"', f'theme "{theme_name}"', content)

        with open(config_path, 'w') as f:
            f.write(content)

        print(f"✅ Theme set to: {theme_name}")
        return True
    except Exception as e:
        print(f"❌ Error setting theme: {e}")
        return False


def create_default_layout(layout_name, layouts_dir):
    """Create a default layout template."""
    import subprocess
    try:
        result = subprocess.run(
            ["zellij", "setup", "--dump-layout", "default"],
            capture_output=True,
            text=True,
            check=True
        )
        if result.returncode == 0:
            layout_path = layouts_dir / f"{layout_name}.kdl"
            with open(layout_path, 'w') as f:
                f.write(result.stdout)
            print(f"✅ Default layout created: {layout_path}")
            return True
        else:
            print(f"❌ Failed to create layout: {result.stderr}")
            return False
    except Exception as e:
        print(f"❌ Error creating layout: {e}")
        return False


def setup_keybindings_hint():
    """Provide hint for setting up keybindings."""
    print("""
📝 Keybinding Setup Tips:

1. Edit ~/.config/zellij/config.kdl
2. Add keybinds section:
   keybinds {
       normal {
           bind "Ctrl g" { SwitchToMode "locked"; }
           bind "Ctrl p" { SwitchToMode "pane"; }
           // ... add more bindings
       }
   }
3. Common modes: normal, pane, locked, shared, session
4. Use 'zellij setup --check' to validate
    """)


def validate_config(config_path):
    """Validate Zellij configuration."""
    import subprocess
    try:
        result = subprocess.run(
            ["zellij", "setup", "--check"],
            capture_output=True,
            text=True,
            check=True
        )
        if result.returncode == 0:
            print("✅ Configuration is valid")
            return True
        else:
            print(f"❌ Configuration errors: {result.stderr}")
            return False
    except Exception as e:
        print(f"❌ Error validating config: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(
            description="Setup Zellij configuration with optional theme and layout",
            formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("--theme", help="Set theme (e.g., nord, dracula, default)")
    parser.add_argument("--layout", help="Create default layout with specified name")
    parser.add_argument("--keybindings", action="store_true", help="Show keybinding setup hints")
    parser.add_argument("--clean", action="store_true", help="Start fresh (clean setup)")
    parser.add_argument("--validate", action="store_true", help="Validate existing configuration")

    args = parser.parse_args()

    # Create config directory
    config_dir = create_config_directory()
    config_path = config_dir / "config.kdl"

    print(f"🚀 Setting up Zellij configuration...")
    print(f"   Config directory: {config_dir}")

    if args.clean:
        print("Starting with clean configuration...")
        if dump_default_config(config_path):
            print("✅ Clean setup complete")
        else:
            sys.exit(1)
        return

    if args.validate:
        if config_path.exists():
            validate_config(config_path)
        else:
            print("❌ No configuration found to validate")
        return

    # Setup basic config if it doesn't exist
    if not config_path.exists():
        print("Creating default configuration...")
        if not dump_default_config(config_path):
            sys.exit(1)

    # Create layouts directory
    layouts_dir = create_layout_directory(config_dir)

    # Set theme if specified
    if args.theme:
        setup_theme(args.theme, config_path)

    # Create default layout if specified
    if args.layout:
        create_default_layout(args.layout, layouts_dir)

    # Show keybinding hints if requested
    if args.keybindings:
        setup_keybindings_hint()

    # Validate final configuration
    if config_path.exists():
        validate_config(config_path)

    print("✅ Zellij setup complete!")
    print(f"📁 Configuration file: {config_path}")
    print(f"📁 Layouts directory: {layouts_dir}")


if __name__ == "__main__":
    main()