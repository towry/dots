all:
    just --list

# Update jj-repo dep
@update-jj:
    nix flake update --update-input jj-repo
