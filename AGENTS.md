# dotfiles Agent Guide

## Build & Deploy
- **Format**: `make format` (runs treefmt with nixfmt-rfc-style on *.nix files)
- **Build/Switch**: `make build` (runs home-manager switch) — DO NOT run, ask user to run manually
- **Darwin rebuild**: `make rebuild` (runs darwin-rebuild switch)
- **Update flake**: `make update-input` (updates nix flake inputs)
- **Git operations**: DO NOT run git commands (commit, push, etc.) — ask user to run manually

## Code Style
- **Nix**: Use nixfmt-rfc-style formatting; follow existing module patterns in nix/hm/ and nix/darwin/
- **Fish**: 2-space indent; functions in conf/fish/funcs/; use `set -l` for locals, `set -f` for function scope
- **Shell**: Use `#!/usr/bin/env bash`; prefer `fd` over `find`, `rg` over `grep`, `jq` for JSON
- **Lua/JSON/Markdown**: 2-space indent (per .editorconfig)
- **Naming**: kebab-case for files/functions; UPPER_CASE for env vars; descriptive names over abbreviations

## Project Structure
- `conf/`: App configs (fish, tmux, yabai, zellij, vim, llm agents/commands)
- `nix/`: Nix modules (hm/ for home-manager, darwin/ for nix-darwin, pkgs/ for custom packages)
- `scripts/`: Standalone utility scripts
- `.github/instructions/`: Domain-specific rules (jj, zellij, repo)

## Key Principles
- **Minimal changes**: Only modify code relevant to the task; avoid over-engineering
- **Reuse first**: Search for existing utilities/patterns before creating new ones (use rg/fd)
- **Clear boundaries**: No demo/mock code in foundational layers; use FIXME/TODO/NOTE annotations
- **Explicit > implicit**: When unclear, list options and ask; fail fast, don't hide bugs
- **Follow house style**: Check .github/instructions/*.md, then search existing implementations

## Documentation
- Read @conf/llm/docs/prompts/agent-maker.md for how to write agent prompt
