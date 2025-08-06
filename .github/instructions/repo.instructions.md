---
applyTo: "**"
description: General rules for this repo
---

This repo is a dotfiles managed by the nix + nix-darwin + home-manager

# Build

Do not run the build command, ask the user to run it manually

# Git Changes

Do not run git command, like `git commit` etc, ask the user to run it manually

# goose recipe

Please create goose recipe files in `./conf/llm/goose-recipes/` folder.

The value of `goose_provider` in `settings` section should be `openrouter`.

Use command `goose recipe validate <recipe_file>` to validate the recipe file.

goose cli understand both format of recipe (desktop version or cli version), goose desktop gui app only understand the desktop version.

# Repo directory structure

- conf: Mostly configuration files for various apps, programs.
- nix: Where the nix modules located.
- scripts: Scripts that manually run to do something else.
