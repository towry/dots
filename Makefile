
all:
	echo "OK"

b:
	home-manager switch --flake .#mac-legacy --experimental-features 'nix-command flakes'
build:
	cachix watch-exec towry -- home-manager switch --flake .#mac-legacy --experimental-features 'nix-command flakes'
build-no-cache:
	home-manager switch --flake .#mac-legacy --experimental-features 'nix-command flakes' --option eval-cache false

update-input:
	nix flake update -- 

.PHONY:
	build build-no-cache update-input b
