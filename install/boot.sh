# script that init all stuff from one line command.

GIT_REPO="https://github.com/towry/dotfiles.git"

set -e

main() {
	# Use colors, but only if connected to a terminal, and that terminal
	# supports them.
	if which tput >/dev/null 2>&1; then
			ncolors=$(tput colors)
	fi
	if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
		RED="$(tput setaf 1)"
		GREEN="$(tput setaf 2)"
		YELLOW="$(tput setaf 3)"
		BLUE="$(tput setaf 4)"
		BOLD="$(tput bold)"
		NORMAL="$(tput sgr0)"
	else
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
		BOLD=""
		NORMAL=""
	fi

	# Only enable exit-on-error after the non-critical colorization stuff,
	# which may fail on systems lacking tput or terminfo
	set -e

	if [ ! -n "$DOTFILES" ]; then
		DOTFILES=~/.dotfiles
	fi

	if [ -d "$DOTFILES" ]; then
		printf "${YELLOW}You already $DOTFILES exists.${NORMAL}\n"
		printf "You'll need to remove $DOTFILES if you want start over.\n"
		exit
	fi

	umask g-w,o-w

	printf "${BLUE}Cloning dotfiles...${NORMAL}\n"
	hash git >/dev/null 2>&1 || {
		echo "Error: git is not installed"
		exit 1
	}

	env git clone --depth=1 $GIT_REPO $DOTFILES || {
		printf "Error: git clone of dotfiles repo failed\n"
		exit 1
	}

	cd $DOTFILES/install
	chmod a+x ./chmod_all_script.sh
	env bash ./chmod_all_script.sh
}

main
