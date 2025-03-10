# 🏠 Dotfiles

[![Build nix cache](https://github.com/towry/dots/actions/workflows/build-nix-cache.yml/badge.svg)](https://github.com/towry/dots/actions/workflows/build-nix-cache.yml)
[![Check Nix flake](https://github.com/towry/dots/actions/workflows/check-flake.yml/badge.svg)](https://github.com/towry/dots/actions/workflows/check-flake.yml)
[![Update flake dependencies](https://github.com/towry/dots/actions/workflows/update-flake.yml/badge.svg)](https://github.com/towry/dots/actions/workflows/update-flake.yml)

A declarative, reproducible, and version-controlled system configuration using Nix, nix-darwin, and home-manager.

## ✨ Overview

This repository contains my personal dotfiles and system configuration managed with Nix. It uses:

- [Nix](https://nixos.org/) - The purely functional package manager
- [nix-darwin](https://github.com/LnL7/nix-darwin) - macOS system configuration
- [home-manager](https://github.com/nix-community/home-manager) - User environment configuration

The configuration is defined as a Nix flake, making it reproducible and easy to deploy across multiple machines.

## 🛠️ Features & Tools

This configuration includes setup for:

### Shell & Terminal

- **Fish Shell** - Default shell with custom plugins and configurations
- **Starship** - Cross-shell prompt with custom theme
- **Tmux** - Terminal multiplexer with custom keybindings and plugins
- **Kitty** - GPU-accelerated terminal emulator (primary)
- **Wezterm** - Alternative terminal emulator (configured but disabled by default)
- **Zellij** - Terminal workspace manager (configured but disabled by default)

### Development Tools

- **Neovim** - Text editor with extensive configuration
- **Git** - Version control with custom aliases and configuration
- **Jj** - Modern version control system (alternative to Git)
- **Lazygit** - Terminal UI for Git
- **Rust** - Rust programming language toolchain
- **Node.js** - JavaScript runtime with fnm, pnpm, and other frontend tools
- **Elixir** - Elixir programming language support
- **Python** - Python programming environment

### System Tools

- **Yabai** - Tiling window manager for macOS
- **Skhd** - Simple hotkey daemon for macOS
- **Karabiner** - Keyboard customization for macOS
- **AutoRaise** - Window focus follows mouse for macOS
- **dark-mode-notify** - Automatically switch themes based on macOS appearance

### CLI Utilities

- **Bat** - A cat clone with syntax highlighting
- **Ripgrep** - Fast search tool
- **Fd** - Simple, fast alternative to find
- **Fzf** - Fuzzy finder
- **Eza** - Modern replacement for ls
- **Zoxide** - Smarter cd command
- **Atuin** - Shell history with search
- **Yazi** - Terminal file manager
- **Bottom** - System monitor
- **Cachix** - Binary cache for Nix

## 🚀 Getting Started

### Prerequisites

- [Nix package manager](https://nixos.org/download.html) (can be installed via the Determinate Systems installer)

### Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/towry/dots.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Install Nix (if not already installed):

   ```bash
   make install-nix
   ```

3. Bootstrap nix-darwin:

   ```bash
   make boot
   ```

4. Apply the configuration:
   ```bash
   make rebuild
   ```

## 🔄 Updating

To update your system after making changes to the configuration:

```bash
make rebuild
```

To update flake inputs (dependencies):

```bash
make update-input
```

## 📝 Notes

- Fish shell is configured as the default shell through nix-darwin, no manual configuration required

- All Nix binaries are available at `$HOME/.nix-profile/bin/`

- You can edit the command prompt with `alt+e`

## 🛠️ Structure

- `flake.nix` - The main entry point for the Nix flake
- `nix/` - Contains all Nix configuration files
  - `darwin/` - nix-darwin specific configuration
  - `hm/` - home-manager specific configuration
  - `modules/` - Shared configuration modules
  - `lib/` - Helper functions and utilities
  - `pkgs/` - Custom package definitions
  - `home.nix` - Main home-manager configuration

## 📚 Resources

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/index.html)
- [home-manager Manual](https://nix-community.github.io/home-manager/index.html)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
