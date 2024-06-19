# dotfiles

Towry's dotfiles managed in The Nix Way with home-manager.

## Getting Started

### home-manager

`home-manager switch --flake .#mac-legacy`

Note, `#mac-legacy` is for old intel mac like x86_64-darwin.

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

## TODO

- [x] deprecate the niv, flake is the future.
