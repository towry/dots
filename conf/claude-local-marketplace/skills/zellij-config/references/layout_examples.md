# Zellij Layout Examples

Collection of layout templates for different use cases and workflows.

## Basic Layouts

### Single Terminal
Simple terminal with full screen:

```kdl
layout {
    pane command="bash"
}
```

### Two Pane Horizontal
Two panes side by side:

```kdl
layout {
    pane split_direction="horizontal" {
        pane size="50%" command="bash"
        pane size="50%" command="bash"
    }
}
```

### Two Pane Vertical
Two panes stacked vertically:

```kdl
layout {
    pane split_direction="vertical" {
        pane size="50%" command="bash"
        pane size="50%" command="bash"
    }
}
```

## Development Layouts

### Development Workspace
Editor with git and terminal panes:

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
    tab name="code" cwd="~/project" focus=true {
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
}
```

### Full Development Setup
Complete development environment with monitoring:

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
    tab name="editor" cwd="~/project" focus=true {
        pane command="nvim" size="70%"
        pane split_direction="horizontal" {
            pane size="50%" split_direction="vertical" {
                pane command="git" {
                    args "status"
                        cwd "~/project"
                }
                pane command="cargo" {
                    args "test"
                        cwd "~/project"
                }
            }
            pane command="htop"
        }
    }
    tab name="server" cwd="~/server" {
        pane command="nvim" size="60%"
        pane split_direction="vertical" {
            pane command="tail" {
                args "-f" "log/production.log"
                    cwd "~/server"
                size="40%"
            }
            pane command="btop" size="40%"
        }
    }
    tab name="database" {
        pane command="psql" {
            args "-U" "postgres"
                cwd "~/server"
        }
    }
}
```

## Monitoring Layouts

### System Monitoring
Multiple monitoring tools:

```kdl
layout {
    tab name="monitoring" split_direction="horizontal" {
        pane command="htop"
        pane command="btop"
        pane command="iotop"
        pane command="nethogs"
    }
}
```

### Resource Monitoring
CPU, memory, disk, and network monitoring:

```kdl
layout {
    tab name="resources" split_direction="horizontal" {
        pane split_direction="vertical" {
            pane command="htop"
            pane command="df" "-h"
        }
        pane split_direction="vertical" {
            pane command="btop"
            pane command="iotop"
        }
        pane command="nethogs"
    }
}
```

### Log Monitoring
Monitor multiple log files:

```kdl
layout {
    tab name="logs" split_direction="horizontal" {
        pane command="tail" {
            args "-f" "/var/log/syslog"
        }
        pane command="tail" {
            args "-f" "/var/log/nginx/access.log"
        }
        pane command="journalctl" {
            args "-f"
        }
    }
}
```

## Tab Templates

### Default Tab Template with Plugins
Standard tab bar and status bar:

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
    // All tabs will use this template unless overridden
}
```

### Compact Tab Template
Minimal UI with compact bar:

```kdl
layout {
    default_tab_template {
        pane size=1 borderless=true {
            plugin location="zellij:compact-bar"
        }
        children
    }
}
```

## Floating Layouts

### Swap Floating Layout
Different arrangements based on pane count:

```kdl
layout {
    swap_floating_layout {
        floating_panes max_panes=1 {
            pane x="25%" y="25%" width="50%" height="50%"
        }
        floating_panes max_panes=2 {
            pane x="10%" y="25%" width="35%" height="50%"
            pane x="55%" y="25%" width="35%" height="50%"
        }
        floating_panes max_panes=3 {
            pane x="0%" y="0%" width="33%" height="50%"
            pane x="33%" y="0%" width="33%" height="50%"
            pane x="66%" y="0%" width="33%" height="50%"
        }
    }
}
```

### Specific Floating Layout
Predefined floating pane positions:

```kdl
layout {
    pane {
        x="10%"
        y="20%"
        width="80%"
        height="60%"
        focus=true
        command="nvim"
    }
    pane {
        x="15%"
        y="70%"
        width="70%"
        height="25%"
        command="htop"
    }
}
```

## Advanced Layouts

### Multi-Project Setup
Work on multiple projects simultaneously:

```kdl
layout {
    tab name="frontend" cwd="~/projects/frontend" {
        pane command="npm" {
            args "start"
            cwd "~/projects/frontend"
        }
        pane command="nvim" {
            cwd "~/projects/frontend"
        }
    }
    tab name="backend" cwd="~/projects/backend" {
        pane command="npm" {
            args "start"
            cwd "~/projects/backend"
        }
        pane command="nvim" {
            cwd "~/projects/backend"
        }
    }
    tab name="docs" cwd="~/projects/docs" {
        pane command="mkdocs" {
            args "serve"
            cwd "~/projects/docs"
        }
    }
}
```

### Database Layout
Development with database management:

```kdl
layout {
    tab name="app" cwd="~/project" {
        pane command="npm" {
            args "start"
            size="60%"
        }
        pane split_direction="vertical" {
            pane command="nvim" {
                size="40%"
            }
            pane command="psql" {
                args "-U" "postgres"
                size="60%"
            }
        }
    }
    tab name="database-tools" {
        pane command="pgadmin" {
            size="50%"
        }
        pane command="dbeaver" {
            size="50%"
        }
    }
}
```

## Special Purpose Layouts

### Git Workflow
Git operations with diff viewer:

```kdl
layout {
    tab name="git" cwd="~/project" {
        pane command="git" {
            args "status"
            size="30%"
        }
        pane command="git" {
            args "log" "--oneline" "-10"
            size="30%"
        }
        pane split_direction="horizontal" {
            pane command="git" {
                args "diff" "--cached"
                size="40%"
            }
            pane command="git" {
                args "diff" "--cached" "HEAD~1"
                size="40%"
            }
        }
    }
}
```

### Container Development
Docker and development tools:

```kdl
layout {
    tab name="containers" {
        pane command="docker" {
            args "ps"
            size="40%"
        }
        pane command="docker-compose" {
            args "ps"
            size="30%"
        }
        pane split_direction="vertical" {
            pane command="docker" {
                args "stats"
                size="50%"
            }
            pane command="lazydocker"
                size="50%"
            }
        }
    }
    tab name="k8s" {
        pane command="kubectl" {
            args "get" "pods" "--watch"
            size="50%"
        }
        pane command="k9s" {
            size="50%"
        }
    }
}
```

## Layout Tips

### Size Specifications
- **Fixed sizes:** `size=10` (exact lines/columns)
- **Percentage sizes:** `size="50%"` (relative to container)
- **Mixed sizing:** Use fixed and percentage as needed

### Split Directions
- **Vertical:** `split_direction="vertical"` (stack top to bottom)
- **Horizontal:** `split_direction="horizontal"` (side by side)

### Common Patterns
1. **Focus on startup:** Add `focus=true` to important panes
2. **Set working directories:** Use `cwd="/path"` for project-specific panes
3. **Naming:** Use descriptive tab names for organization
4. **Templates:** Use `default_tab_template` for consistent UI
5. **Plugins:** Integrate tab-bar and status-bar for better UX

### Best Practices
- Keep layouts readable with proper indentation
- Use consistent naming conventions
- Test layouts before deploying
- Document custom layouts for team sharing
- Consider different screen sizes when designing layouts