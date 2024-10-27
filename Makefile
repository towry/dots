.PHONY: install-nix uninstall-nix switch setup build build-all x86_64-linux aarch64-linux aarch64-darwin

UNAME := $(shell uname)
NIX_PROFILE := /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh


all:
	echo "OK"

$(NIX_PROFILE):
	curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

install-nix: $(NIX_PROFILE)

b:
	home-manager switch --flake .#mac-legacy --experimental-features 'nix-command flakes'
build:
	cachix watch-exec dots -- home-manager switch --flake .#mac-legacy --experimental-features 'nix-command flakes'
build-no-cache:
	home-manager switch --flake .#mac-legacy --experimental-features 'nix-command flakes' --option eval-cache false

update-input:
	nix flake update -- 

.PHONY:
	build build-no-cache update-input b
