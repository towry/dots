#!/usr/bin/env python3
"""
Zellij Layout Creator - Generate custom layouts from templates or parameters

Usage:
    create_layout.py [LAYOUT_TYPE] [OPTIONS]

Layout Types:
    dev        - Development layout with editor and git
    monitor    - Monitoring layout with system metrics
    terminal   - Simple terminal layout
    custom     - Interactive custom layout creation

Examples:
    create_layout.py dev --name myproject
    create_layout.py monitor --theme nord
    create_layout.py terminal --horizontal-split 2
    create_layout.py custom --panes 3 --direction vertical
"""

import argparse
import os
import sys
from pathlib import Path


LAYOUT_TEMPLATES = {
    "dev": """layout {
    default_tab_template {{
        pane size=1 borderless=true {{
            plugin location="zellij:tab-bar"
        }}
        children
        pane size=2 borderless=true {{
            plugin location="zellij:status-bar"
        }}
    }}
    tab name="{name}" cwd="{cwd}" focus=true {{
        pane command="nvim" size="80%"
        pane size="20%" split_direction="vertical" {{
            pane command="git" {{
                args "status"
                size="50%"
            }}
            pane command="htop"
        }}
    }}
    tab name="terminal" {{
        pane command="bash"
    }}
}}""",

    "monitor": """layout {{
    default_tab_template {{
        pane size=1 borderless=true {{
            plugin location="zellij:tab-bar"
        }}
        children
        pane size=2 borderless=true {{
            plugin location="zellij:status-bar"
        }}
    }}
    tab name="monitoring" split_direction="horizontal" {{
        pane command="htop"
        pane command="btop"
        pane command="iotop"
        pane command="nethogs"
    }}
}}""",

    "terminal": """layout {{
    tab name="main" {{
        pane command="bash"{split}
    }}
}}"""
}


def create_custom_layout(panes, direction, name):
    """Create a custom layout with specified number of panes."""
    if direction == "horizontal":
        split_attr = 'split_direction="horizontal"'
    else:
        split_attr = 'split_direction="vertical"'

    layout = f'''layout {{
    tab name="{name}" {{
        pane command="bash"
        {split_attr} {{
'''

    # Add panes
    for i in range(1, panes):
        if i == panes:
            layout += f'            pane command="bash"\n'
        else:
            layout += f'            pane command="bash"\n'

    layout += f'        }}\n    }}\n}}'''

    return layout


def get_layout_path(layouts_dir, layout_name):
    """Get full path for layout file."""
    return layouts_dir / f"{layout_name}.kdl"


def write_layout_file(layout_path, content):
    """Write layout content to file."""
    try:
        layout_path.parent.mkdir(parents=True, exist_ok=True)
        with open(layout_path, 'w') as f:
            f.write(content)
        return True
    except Exception as e:
        print(f"❌ Error writing layout file: {e}")
        return False


def get_layout_cwd():
    """Get current working directory for layout."""
    return os.getcwd()


def main():
    parser = argparse.ArgumentParser(description="Create Zellij layouts from templates")
    parser.add_argument("layout_type", choices=["dev", "monitor", "terminal", "custom"],
                      help="Type of layout to create")
    parser.add_argument("--name", default="workspace",
                      help="Name for the layout (default: workspace)")
    parser.add_argument("--cwd", help="Working directory for layout (default: current directory)")
    parser.add_argument("--theme", help="Theme to apply (e.g., nord, dracula)")

    # Custom layout options
    parser.add_argument("--panes", type=int, default=2,
                      help="Number of panes for custom layout (default: 2)")
    parser.add_argument("--direction", choices=["horizontal", "vertical"], default="horizontal",
                      help="Split direction for custom layout (default: horizontal)")

    args = parser.parse_args()

    # Determine layouts directory
    layouts_dir = Path.home() / ".config" / "zellij" / "layouts"

    # Get layout name and cwd
    layout_name = args.name
    cwd = args.cwd or get_layout_cwd()

    print(f"🚀 Creating {args.layout_type} layout...")

    # Generate layout content
    if args.layout_type == "custom":
        content = create_custom_layout(args.panes, args.direction, layout_name)
    elif args.layout_type in LAYOUT_TEMPLATES:
        content = LAYOUT_TEMPLATES[args.layout_type].format(
            name=layout_name,
            cwd=cwd
        )
    else:
        print(f"❌ Unknown layout type: {args.layout_type}")
        sys.exit(1)

    # Add theme if specified
    if args.theme:
        content += f'\ntheme "{args.theme}"\n'

    # Write layout file
    layout_path = get_layout_path(layouts_dir, layout_name)
    if write_layout_file(layout_path, content):
        print(f"✅ Layout created: {layout_path}")
        print(f"💡 Use with: zellij --layout {layout_path}")
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()