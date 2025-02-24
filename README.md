[![Build nix cache](https://github.com/towry/dots/actions/workflows/build-nix-cache.yml/badge.svg)](https://github.com/towry/dots/actions/workflows/build-nix-cache.yml)
[![Check Nix flake](https://github.com/towry/dots/actions/workflows/check-flake.yml/badge.svg)](https://github.com/towry/dots/actions/workflows/check-flake.yml)
[![Update flake dependencies](https://github.com/towry/dots/actions/workflows/update-flake.yml/badge.svg)](https://github.com/towry/dots/actions/workflows/update-flake.yml)

# dotfiles

Towry's dotfiles managed in The Nix Way with nix-darwin/home-manager.

## Getting Started

### With home-manager

`make build`

All nix bins is available at:

```
$HOME/.nix-profile/bin/
```

- [Install home-manager on
  macOS](https://nix-community.github.io/home-manager/index.xhtml#sec-install-standalone)
- [Options](https://nix-community.github.io/home-manager/options.xhtml)
- Run `sudo vi /etc/shells` and add the output of `which fish`
  (`$HOME/.nix-profile/bin/fish`) as an entry.
- Run `chsh -s $(which fish)`.

### With nix-darwin

First run:

`make boot`

Afterwards, run: `make rebuild`.

## TODO

## Edit the prompt with $EDITOR.

- `alt+e` to edit the prompt.
