.PHONY: install-nix uninstall-nix switch setup build build-all x86_64-linux aarch64-linux aarch64-darwin

UNAME := $(shell uname)
NIX_PROFILE := /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
WHOAMI := $(shell whoami)


all:
	echo "$(WHOAMI) - ${UNAME}"

$(NIX_PROFILE):
	curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

install-nix: $(NIX_PROFILE)

build:
	home-manager switch --flake .#${WHOAMI} --experimental-features 'nix-command flakes'
buildc:
	cachix watch-exec dots -- make build

update-input:
	nix flake update --
boot:
	nix --extra-experimental-features nix-command --extra-experimental-features flakes run nix-darwin -- switch --flake .
rebuild:
	darwin-rebuild switch --flake .

.PHONY:
	build build-no-cache update-input b boot rebuild
