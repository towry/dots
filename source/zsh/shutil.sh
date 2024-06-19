#!/usr/bin/bash
# Git
function xtree() {
  find . -print | grep -v .git | sed -e 's;[^/]*/;|____;g;s;____|; |;g' | less
}

function xbn() {
  git branch | sed -n -e 's/^\* \(.*\)/\1/p'
}

gco() {
    git checkout $1 2>&1 | \
    if grep -q "fatal: '$1' is already checked out"; \
    then \
        local selected_workspace=$(git worktree list | awk '{print $1, $NF}' | awk '{print $1, $NF}' | fzf --exact --filter="$1" | head -n 1 | awk '{print $1}')
        if [[ -n "$selected_workspace" ]]; then \
            cd "$selected_workspace"; \
        fi; \
    fi
}

function xpush() {
  local a=$1
  if [ -z "$1" ]
  then
    a='origin'
  fi
  echo "git push $a `xbn`"
  sleep 1
  git push $a `xbn`
}

function xpull() {
  local a=$1
  if [ -z "$1" ]
  then
	a='origin'
  fi
  echo "git pull $a `xbn`"
  sleep 1
  git pull $a `xbn`
}

function gpp() {
  local a=$1
  if [ -z "$1" ]
  then
	a='origin'
  fi
  echo "git pull -p $a `xbn`"
  sleep 1
  git pull -p $a `xbn`
}

function xpr() {
  local a=$1
  if [ -z "$1" ]
  then
	a='origin'
  fi
  echo "git pull --rebase $a `xbn`"
  sleep 1
  git pull --rebase $a `xbn`
}

function xdesc() {
  local a=$1
  if [ -z "$1" ]
  then
    a="`xbn`"
  fi
  git config branch.${a}.description
}

function xedit-desc() {
  git branch --edit-description
}

# If path to add is not a directory, then it will not add to path.
pathadd() {
  newelement=${1%/}
  if [ -d "$1" ] && ! echo $PATH | grep -E -q "(^|:)$newelement($|:)" ; then
    if [ "$2" = "after" ] ; then
      PATH="$PATH:$newelement"
    else
      PATH="$newelement:$PATH"
    fi
  fi
}

pathrm() {
  PATH="$(echo $PATH | sed -e "s;\(^\|:\)${1%/}\(:\|\$\);\1\2;g" -e 's;^:\|:$;;g' -e 's;::;:;g')"
}

useproxy() {
  export https_proxy=http://127.0.0.1:1080 http_proxy=http://127.0.0.1:1080 all_proxy=socks5://127.0.0.1:1080
}

cleangitbr() {
  for branch in $(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}'); do git branch -D $branch; done
}
