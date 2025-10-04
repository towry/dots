all:
    just --list

@update-self-repo:
    nix flake update nix-priv --refresh
