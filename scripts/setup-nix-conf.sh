#!/usr/bin/env bash

# modify /etc/nix/conf
# add the following line to /etc/nix/nix.conf
# trusted-users = root @staff
# substituters = https://dots.cachix.org https://nix-community.cachix.org https://towry.cachix.org https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/
# trusted-public-keys = dots.cachix.org-1:H/gV3a5Ossrd/R+qrqrAk9tr3j51NHEB+pCTOk0OjYA= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= towry.cachix.org-1:7wS4ROZkLQMG6TZPt4K6kSwzbRJZf6OiyR9tWgUg3hY=
# experimental-features = nix-command flakes
