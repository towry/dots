# https://ampcode.com/manual/appendix#permissions-reference
# Amp permissions configuration
[
  # Version Control Systems (VCS) - Common operations allowed
  {
    tool = "Bash";
    matches.cmd = "/^git (status|diff|log|show|rev-parse)$/";
    action = "allow";
  }
  {
    tool = "Bash";
    matches.cmd = "/^jj (st|status|log|diff|show)$/";
    action = "allow";
  }

  # VCS - Write/Destructive operations - require user approval
  {
    tool = "Bash";
    matches.cmd = "git commit*";
    action = "ask";
  }
  {
    tool = "Bash";
    matches.cmd = "git ci*";
    action = "ask";
  }
  {
    tool = "Bash";
    matches.cmd = "git push*";
    action = "ask";
  }
  {
    tool = "Bash";
    matches.cmd = "jj commit*";
    action = "ask";
  }
  {
    tool = "Bash";
    matches.cmd = "jj ci*";
    action = "ask";
  }
  {
    tool = "Bash";
    matches.cmd = "jj push*";
    action = "ask";
  }
  {
    tool = "Bash";
    matches.cmd = "jj abandon*";
    action = "ask";
  }
  {
    tool = "Bash";
    matches.cmd = "jj drop*";
    action = "ask";
  }
  {
    tool = "Bash";
    matches.cmd = "jj rebase*";
    action = "ask";
  }

  # File System & Shell Utilities
  {
    tool = "Bash";
    matches.cmd = "ls*";
    action = "allow";
  }
  {
    tool = "Bash";
    matches.cmd = "fd*";
    action = "allow";
  }
  {
    tool = "Bash";
    matches.cmd = "rg*";
    action = "allow";
  }
  {
    tool = "Bash";
    matches.cmd = "cd *";
    action = "allow";
  }
  {
    tool = "Bash";
    matches.cmd = "pwd";
    action = "allow";
  }
  {
    tool = "Bash";
    matches.cmd = "cat *";
    action = "allow";
  }
  {
    tool = "Bash";
    matches.cmd = "head *";
    action = "allow";
  }
  {
    tool = "Bash";
    matches.cmd = "tail *";
    action = "allow";
  }
  {
    tool = "Bash";
    matches.cmd = "mkdir *";
    action = "allow";
  }
  {
    tool = "Bash";
    matches.cmd = "rm *";
    action = "ask";
  }

  # File Operations
  {
    tool = "read_file";
    matches.path = "/Users/towry/.dotfiles/**";
    action = "allow";
  }
  {
    tool = "read_file";
    matches.path = "/Users/towry/workspace/**";
    action = "allow";
  }
  {
    tool = "read_file";
    matches.path = "/tmp/**";
    action = "allow";
  }
  {
    tool = "read_file";
    matches.path = ".claude/**";
    action = "allow";
  }
  {
    tool = "create_file";
    action = "allow";
  }
  {
    tool = "edit_file";
    action = "allow";
  }

  # Denied Paths
  {
    tool = "read_file";
    matches.path = "**/.env*";
    action = "deny";
  }
  {
    tool = "read_file";
    matches.path = "**/secrets/**";
    action = "deny";
  }
  {
    tool = "read_file";
    matches.path = "**/.ssh/**";
    action = "deny";
  }
  {
    tool = "read_file";
    matches.path = "**/.gnupg/**";
    action = "deny";
  }

  # MCP Tools
  {
    tool = "mcp__*";
    action = "allow";
  }

  # Languages & Build Tools
  {
    tool = "Bash";
    matches.cmd = "cargo check*";
    action = "allow";
  }
  {
    tool = "Bash";
    matches.cmd = "cargo test*";
    action = "allow";
  }
  {
    tool = "Bash";
    matches.cmd = "cargo clippy*";
    action = "allow";
  }
  {
    tool = "Bash";
    matches.cmd = "cargo build --release*";
    action = "ask";
  }
  {
    tool = "Bash";
    matches.cmd = "nix flake*";
    action = "allow";
  }
  {
    tool = "Bash";
    matches.cmd = "darwin-rebuild switch*";
    action = "ask";
  }
  {
    tool = "Bash";
    matches.cmd = "home-manager switch*";
    action = "ask";
  }

  # Network
  {
    tool = "Bash";
    matches.cmd = "curl*";
    action = "allow";
  }
]
