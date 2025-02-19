{
  pkgs,
  theme,
  username,
  # config,
  ...
}:
{
  home.sessionVariables = {
    _ZO_ECHO = 1;
    _ZO_EXCLUDE_DIRS = "$HOME:$HOME/private/*:/usr/*:$HOME/Library/*:$HOME/.local/*";
    TMUX_AUTO_ATTACH = 0;
    LC_ALL = "en_US.UTF-8";
    LANG = "en_US.UTF-8";
    STARSHIP_LOG = "error";
  };
  programs = {
    carapace.enableFishIntegration = true;
    kitty.shellIntegration.enableFishIntegration = true;
    fish = {
      enable = true;
      plugins = [
        {
          name = "foreign-env";
          inherit (pkgs.fishPlugins.foreign-env) src;
        }
        {
          name = "sponge";
          inherit (pkgs.fishPlugins.sponge) src;
        }
        {
          name = "fifc";
          # src = pkgs.fetchFromGitHub {
          #   owner = "ollehu";
          #   repo = "fifc";
          #   rev = "26c5863f7f44a5f7e375cbda6806839acd121c8e";
          #   sha256 = "sha256-EO2QO5TgZB/Fhu+75MAvTwIthUiRtHrUMhOntyF+vBo=";
          # };
          inherit (pkgs.fishPlugins.fifc) src;
        }
        {
          # type .... will expand to ../..
          name = "puffer-fish";
          src = pkgs.fetchFromGitHub {
            owner = "nickeb96";
            repo = "puffer-fish";
            rev = "12d062eae0ad24f4ec20593be845ac30cd4b5923";
            sha256 = "sha256-2niYj0NLfmVIQguuGTA7RrPIcorJEPkxhH6Dhcy+6Bk=";
          };
        }
      ];
    };
    zoxide = {
      enableFishIntegration = true;
    };
  };
  home.file.fishThemes = {
    enable = true;
    target = ".config/fish/themes";
    source = ../../conf/fish/themes;
  };

  # aliases
  programs.fish.shellAliases = {
    cd-home = "cd $HOME/workspace";
    run-firefox-debugger =
      if pkgs.stdenv.isDarwin then
        "/Applications/Firefox.app/Contents/MacOS/firefox --start-debugger-server"
      else
        "/user/bin/firefox --start-debugger-server";
    wz = "wezterm";
    wz-rename = "wezterm cli rename-workspace";
    split-pane = "wezterm cli split-pane";
    cls = "clear";
    vi = "nvim";
    lazy = "NVIM_APPNAME=lazy nvim";
    # temporary for lazy branch dev
    astro = "NVIM_APPNAME=astro nvim";
    q = "exit";
    qq = "exit && exit && exit";
    gcd = "cd-gitroot";
    git-conflict-rm = "git status | grep 'deleted by us' | sed 's/deleted by us: //' | xargs git rm";
    j0 = "jump-first";
    ji = "jump";
    nix-proxy = "sudo /usr/bin/env python ~/.dotfiles/bin/darwin-nix-proxy.py";
    cachix-exec = "cachix watch-exec towry --";
    g = "git";
    gts = "gits";
    gac = ''echo "$()$(tput setaf 3)warning: be carefull$(tput sgr0)" && git add . && git commit'';
    gcz = ''echo "$(tput bold)$(tput setaf 3)warning: be carefull$(tput sgr0)" && git add . && git cz'';
    gtail = "git rev-list --all | tail";
    ggrep = "git rev-list --all | xargs git grep --break";
    tig = "TERM=xterm-256color ${pkgs.tig}/bin/tig";
    lg = "lazygit";
    flog = "glog";
    xmerge = "git merge --ff";
    xmerged = "git branch --merged master";
    dot-proxy = "export CURL_NIX_FLAGS='-x http://127.0.0.1:1080' https_proxy=http://127.0.0.1:1080 http_proxy=http://127.0.0.1:1080 all_proxy=socks5://127.0.0.1:1080";
    up-karabiner = "jq . ~/.config/karabiner/karabiner.json | sponge ~/.config/karabiner/karabiner.json && gh gist edit 072fd7c32c1fc0b33044d0915885b3b4 -f karabiner.json ~/.config/karabiner/karabiner.json";
    list-zombie-ps = "ps aux | grep -w Z";
    parent-pid-of = "ps o ppid";
    pn = "pnpm";
    make-neovim = "make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=$HOME/.local";
    nvim-lazy-install = "nvim --headless \"+Lazy! install\" +qa && echo 'done'";
    kitty-list-fonts = "kitty +list-fonts --psnames";
    ghc = "gh copilot";
    ghcp = "gh copilot explain";
    zj = "zellij";
    zjr = "zellij run";
    zj-in = "zellij attach -c towry";
    zj-run-tasks = ''
      zellij action start-or-reload-plugin file:$HOME/.config/zellij/plugins/multitask.wasm --configuration "shell=$SHELL,cwd=`pwd`"
    '';
    emptytrash = "sudo rm -rf ~/.Trash/*";
    kittyconf = "nvim ~/.config/kitty/kitty.conf";
    stop-yabai = "yabai --stop-service";
    start-yabai = "yabai --start-service";
    # yabaiconf="nvim ~/.config/yabai/yabairc";
    skhdconf = "nvim ~/.config/skhd/skhdrc";
    tmuxin = "tmux new-session -A -s tmux";
    quickterm = "tmux new-session -A -s quickterm -c $HOME/workspace";
    tm-rw = "tmux rename-window";
    tm-rs = "tmux rename-session";
    tail-tmp-log = "tail -f (fd --type file --search-path /tmp | fzf)";
    random-name = "uclanr";
    tree = "${pkgs.eza}/bin/eza --tree --git-ignore --group-directories-first -L8";
    nix-shell-run-nix-info = "nix-shell -p nix-info --run \"nix-info -m\"";
  };

  programs.fish.shellInit = ''
    set -g fish_prompt_pwd_dir_length 20
    set -x GPG_TTY (tty)
    set -x DARKMODE dark
    set -g __fish_ls_command ${pkgs.eza}/bin/eza
    #########
    if test -e $HOME/.private.fish
        source $HOME/.private.fish
    end

    fish_add_path --path --append $HOME/.local/bin
  '';
  ## do not foget to run fish --login to generate new fish_variables file.
  # https://github.com/LnL7/nix-darwin/issues/122
  programs.fish.loginShellInit = ''
    set -U fish_greeting ""
    set -Ux fifc_editor nvim
    # set -U fifc_keybinding \cf
    set -U fifc_fd_opts --hidden
  '';

  programs.fish.interactiveShellInit = ''
    set fish_cursor_default block blink
    set fish_cursor_insert underscore blink
    set -U fifc_custom_fzf_opts +e

    if test "$DARKMODE" = "dark"
        fish_config theme choose "${theme.fish.dark}"
    else
        fish_config theme choose "${theme.fish.light}"
    end

    # fish_add_path $HOME/.nimble/bin
    fish_add_path /etc/profiles/per-user/${username}/bin
    fish_add_path /run/current-system/sw/bin
  '';

  programs.fish.functions = {
    # _prompt_move_to_bottom = {
    #   onEvent = "fish_postexec";
    #   body = "tput cup $LINES";
    # };
    nix-clean = {
      description = "Run Nix garbage collection and remove old kernels to free up space in boot partition";
      body = ''
        # NixOS-specific steps
        if test -f /etc/NIXOS
          sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +3
          for link in /nix/var/nix/gcroots/auto/*
              rm $(readlink "$link")
          end
        end
        nix-env --delete-generations old
        nix-store --gc
        nix-channel --update
        nix-env -u --always
        nix-collect-garbage -d
      '';
    };
    random-folder = {
      description = "Return a random folder name";
      body = ''
        set -l temp_folder (mktemp -d)
        set -l folder_name (basename $temp_folder)
        set -l folder_name (string split '.' $folder_name)[-1]
        set -l folder_name (string sub -l 3 $folder_name)
        set -l month (date +%m)
        set -l day (date +%d)
        set -l folder_name "$folder_name$month$day"
        printf "%s" $folder_name
      '';
    };
    xbn = {
      body = ''
        git branch | sed -n -e 's/^\* \(.*\)/\1/p'
      '';
      description = "Get git branch";
    };
    batail = {
      body = ''
        tail -f $argv | ${pkgs.bat}/bin/bat --paging=never -l log
      '';
      description = "Tail with bat";
    };
    __fish_git_prune_branch_complete = ''
      set -l branches (git branch --format='%(refname:short)' 2>/dev/null)
      for branch in $branches
          echo $branch
      end
    '';
    rgp = {
      body = ''
        ${pkgs.ripgrep}/bin/rg -p $argv | less -RFX
      '';
      description = "ripgrep with pager";
    };
    determine_preview_position = {
      body = ''
        # Get the current terminal size
        set cols (stty size | awk '{print $2}')
        set rows (stty size | awk '{print $1}')

        # Decide on preview window location based on the size
        if test $cols -gt 80
            echo "right:50%"
        else if test $rows -gt 30
            echo "up:50%"
        else
            echo "hidden"
        end
      '';
      description = "Determine fzf preview window position based on terminal size";
    };
    xpush = {
      body = ''
        set a $argv[1]
        set br (xbn)
        if test -z "$a"
            set a 'origin'
        end
        echo "git push -u $a $br"
        sleep 1
        git push -u $a $br
      '';
      description = "git push util";
    };
    gpp = {
      body = ''
        set a $argv[1]
        set br (xbn)
        if test -z "$a"
            set a 'origin'
        end
        echo "git pull --ff $a $br"
        sleep 1
        git pull --ff $a $br
      '';
      description = "git pull util";
    };
    gco = {
      body = ''
        git checkout $argv 2>&1 | \
        if grep -q "fatal: '$argv' is already checked out"
            set selected_workspace (git worktree list | awk '{print $1, $NF}' | awk '{print $1, $NF}' | fzf --exact --filter="$argv" | head -n 1 | awk '{print $1}')
            if test -n "$selected_workspace"
                echo "$selected_workspace"
                cd "$selected_workspace"
            else
                echo "Error: no branch found"
                exit 1
            end
        end
      '';
      description = "Git checkout with awareness of worktree";
    };
    gwt = {
      body = ''
        # git worktree list | awk '{print $1}' | fzf --reverse --bind 'ctrl-o:execute($EDITOR {} &> /dev/tty)'
        set worktree (git worktree list | awk '{print $1, $NF}' | awk -v home="$HOME" '{sub(home, "~"); print $1, $NF}' | fzf --exact --reverse -1 -0 --query=$argv[1] | awk '{print $1}')
        if test -n "$worktree"
            eval cd $worktree
        end
      '';
      description = "change git worktree";
    };
    gwj = {
      body = ''
        if test -z $argv[2] && test "$argv[1]" = "-"
            if not git rev-parse --is-inside-work-tree > /dev/null 2>&1
                z $argv[1]
                return
            end
            gwt $argv[1]
            return
        else if test "$argv[1]" = "-"
            gwt $argv[2]
            return
        end
        # use zi in case there are multiple candidates.
        set target_dir (string replace "~" " " -- $argv[1])
        eval "zi $target_dir"
        # Check if current directory is a Git repository
        if not git rev-parse --is-inside-work-tree > /dev/null 2>&1
            return
        end
        gwt $argv[2]
      '';
      description = "jump to dir and change workspace";
    };
    git-list-changed-files = {
      body = ''
        set -l default_branch

        if git rev-parse --verify master >/dev/null 2>/dev/null
            set default_branch master
        else if git rev-parse --verify main >/dev/null 2>/dev/null
            set default_branch main
        else
            echo "Neither master nor main branches found."
            return 1
        end

        # update local main branch
        git fetch origin $default_branch >/dev/null 2>&1

        git diff --name-only origin/$default_branch...
      '';
      description = "git list changed files";
    };
    git-cob = {
      body = ''
        set -l default_branch

        if git rev-parse --verify master >/dev/null 2>/dev/null
            set default_branch master
        else if git rev-parse --verify main >/dev/null 2>/dev/null
            set default_branch main
        else
            echo "Neither master nor main branches found."
            return 1
        end

        # update local main branch
        git fetch origin $default_branch
        git merge --ff --commit --no-edit -s recursive -Xtheirs origin/$default_branch

        if set -q argv[1]
            echo "Creating new branch '$argv[1]' based on '$default_branch'"
            git checkout -b $argv[1] $default_branch
        else
            echo "Please specify the new branch name."
            return 1
        end
      '';
      description = "Git checkout branch";
    };
    git-sync = {
      body = ''
         set -l default_branch

         if git rev-parse --verify master >/dev/null 2>/dev/null
             set default_branch master
         else if git rev-parse --verify main >/dev/null 2>/dev/null
             set default_branch main
         else
             echo "Neither master nor main branches found."
             return 1
         end

        if test (git rev-parse --abbrev-ref HEAD) = $default_branch
             echo "Cannot merge $default_branch into itself."
             return 1
         end

         git fetch origin $default_branch
         git merge --no-ff --no-commit origin/$default_branch

         echo "Merged `$default_branch` into current branch."
      '';
      description = "Git sync with branch";
    };
    tmux-switch = {
      # TODO: tmux enable check.
      body = ''
        if test (count $argv) -eq 0
            tmux switch-client -l
        else
            tmux switch-client -t $argv[1]
        end
      '';
      description = "Tmux switch client";
    };
    cd-finder = {
      # TODO: system check.
      body = ''
        if [ -x /usr/bin/osascript ]
          set -l target (osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)')
          if [ "$target" != "" ]
            cd "$target"; pwd
          else
            echo 'No Finder window found' >&2
          end
        end
      '';
      description = "Cd into current opened finder";
    };
    fstatus = {
      body = ''
        # Ensure we are in a git repository
        set git_root (git rev-parse --show-toplevel)
        if test $status -ne 0
            echo "Not a git repository."
            return
        end

        # Define the command to list changed files with full path
        set git_diff_cmd "git diff --name-only"

        # Define the preview command for fzf
        # Prepend the Git root directory to the file path
        set preview_cmd "git diff --color=always -- $git_root/{}"

        # Determine the preview window position
        set preview_pos (determine_preview_position)

        # Execute the fzf command with the dynamically determined preview window position
        eval $git_diff_cmd | fzf --preview "$preview_cmd" \
                                 --preview-window "$preview_pos" \
                                 --bind "enter:execute(git diff --color=always -- $git_root/{} | less -R > /dev/tty)" \
                                 --bind "ctrl-u:preview-page-up" \
                                 --bind "ctrl-d:preview-page-down"
      '';
      description = "Use fzf to browse current unstaged changes";
    };
    fpick-status = {
      body = ''
        # Ensure we are in a git repository
        if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
            echo "Not a git repository."
            return 1
        end

        # Use git to list changed files and pipe into fzf
        set selected_file (git diff --name-only | fzf)

        # Check if a file was selected
        if test -z "$selected_file"
            echo "No file selected."
            return 1
        end

        set need_confirm 1
        # check if -y is provided after this command to indicate no confirm
        if set -q argv[1] && test $argv[1] = "-y"
            set need_confirm 0
        end

        # Check if any additional arguments were provided (command to execute)
        if set -q argv[1]
            # Arguments were provided, so a command is intended to be executed
            set command $argv
            if test $need_confirm -eq 0
                set command $argv[2..-1]
            end

            if test $need_confirm -eq 0
                eval $command $selected_file
                return
            end

            read -l confirm -P "Are you sure? [y/N] "
            switch $confirm
                case Y y
                    eval $command $selected_file
                case '*'
                    echo "Operation cancelled."
                    return 1
            end
        else
            # No additional arguments – simply return the selected file for piping
            echo $selected_file
        end
      '';
      description = "Pick file from git status";
    };
    git-prune-branch = {
      body = ''
        set branch_name $argv[1]

        # Delete local branch
        git branch -D $branch_name

        if test $status -ne 0
          return
        end

        echo "Deleting the remote branch, may fail"
        # Delete corresponding remote branch (if exists)
        git push origin --delete $branch_name 2>/dev/null
      '';
      description = "Delete branch local and remote";
    };
    __git_search_preview_command = {
      body = ''
        set -l commit_id (string split " " $commit)[1]
        set -l commit_message (string join " " (string split " " $commit)[2..-1])
        git show $commit_id | rg --colors 'match:fg:magenta' --colors 'line:bg:yellow' --color=always --passthru -- "$keyword"
      '';
      noScopeShadowing = true;
      argumentNames = [
        "commit"
        "keyword"
      ];
    };
    __git_search_command = {
      body = ''
        set -l keywords (string trim -- $keyword)
        if test -z "$keywords"
            git log --oneline --max-count=3
        else
            git log -G"$keywords" --oneline --max-count=800
        end
      '';
      noScopeShadowing = true;
      argumentNames = [ "keyword" ];
    };
    git-search = {
      body = ''
        set -l keyword "$argv"
        set preview_pos (determine_preview_position)
        set -l view_diff "echo {} | grep -o '[a-f0-9]\{7\}' | head -1"

        __git_search_command $keyword | fzf \
            --preview "__git_search_preview_command {} {q}" \
            --preview-window "$preview_pos" \
            --bind "enter:execute:$view_diff | TERM=xterm-256color ${pkgs.tig}/bin/tig show --stdin" \
            --bind "ctrl-u:preview-page-up,ctrl-d:preview-page-down" \
            --bind "change:reload:sleep 0.8; __git_search_command {q} || true" \
            --ansi --phony --query "$keyword" | awk '{ print $1 }'
      '';
      description = "Search in git history";
    };
    glog = {
      body = ''
        set -l log_line_to_hash "echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
        set -l view_commit "$log_line_to_hash | xargs -I % sh -c 'git show --color=always % | less -R'"
        set -l copy_commit_hash "$log_line_to_hash | pbcopy"
        set -l git_checkout "$log_line_to_hash | xargs -I % sh -c 'git checkout %'"
        set -l view_commit_files "$log_line_to_hash | xargs -I % sh -c 'git diff-tree --no-commit-id --name-only % -r' | fzf | xargs -I % sh -c 'cd \"$(git rev-parse --show-toplevel)\" ; $EDITOR %' sh"
        set -l open_cmd "open"

        if test (uname) = Linux
            set open_cmd "xdg-open"
        end

        set github_open "$log_line_to_hash | xargs -I % sh -c '$open_cmd https://github.\$(git config remote.origin.url | cut -f2 -d. | tr \':\' /)/commit/%'"

        set -l preview_pos (determine_preview_position)

        git log --color=always --format='%C(auto)%h%d %s %C(green)%C(bold)%cr% C(blue)%an' | \
            fzf --no-sort --reverse --tiebreak=index --no-multi --ansi \
                --preview="$view_commit" \
                --preview-window "$preview_pos" \
                --header="View(CR), Hash(C-Y), Github(C-O), Checkout(C-X), Files(C-F)" \
                --bind "enter:execute:$view_commit" \
                --bind "ctrl-y:execute:$copy_commit_hash" \
                --bind "ctrl-x:execute:$git_checkout" \
                --bind "ctrl-f:execute($view_commit_files)+abort" \
                --bind "ctrl-o:execute:$github_open" \
                --bind "ctrl-d:preview-page-down,ctrl-u:preview-page-up"
      '';
      description = "Git browse commits";
    };
    ya = {
      body = ''
        set tmp (mktemp -t "yazi-cwd.XXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        		cd -- "$cwd"
        end
        rm -f -- "$tmp"
      '';
      description = "Yazi";
    };
    pick-folder = {
      body = ''
        set -l folder (fd --type d -E 'node_modules' -E 'dist' -E '.git' --search-path $HOME/workspace --search-path $HOME/moseeker --search-path $HOME/Projects --one-file-system 2> /dev/null | fzf --height 40%)
        if test -n "$folder"
            printf "%s" "$folder"
        end
      '';
      description = "Pick folder with fzf";
    };
    list-fish-alias = ''
      set selected_alias (cat ~/.config/fish/config.fish | grep "alias " | fzf --preview "echo {}" --preview-window "up:60%" | awk -F'[= ]' '{printf "%s", $2}' | string trim)
      if test -n "$selected_alias"
          printf "%s" $selected_alias
      end
    '';
    jump = {
      body = ''
        set -l query "$argv"
        set result (zoxide query --list --exclude $PWD | ${pkgs.path-git-format}/bin/path-git-format --filter --no-bare -f"{path} [{branch}]" | awk -v home="$HOME" '{gsub(home, "~", $1); print $0}' | fzf --height ~60% --reverse --tiebreak=index -1 -0 --exact --query="$query")
        if test -n "$result"
            set directory (echo $result | awk -F' ' '{print $1}' | awk -F'[' '{print $1}')
            if test "$_ZO_ECHO" = "1"
                echo "$directory"
            end
            eval cd $directory
        end
      '';
      description = "Zoxide jump with git branch in path";
    };
    jump-first = {
      body = ''
        set -l query "$argv"
        set result (zoxide query --list --exclude $PWD | path-git-format --filter --no-bare -f"{path} [{branch}]" | fzf --tiebreak=index --exact --filter="$query" --no-sort --nth=4.. --delimiter='[\/\s]' | head -n 1)
        if test -n "$result"
            set directory (echo $result | awk -F' ' '{print $1}' | awk -F'[' '{print $1}')
            if test "$_ZO_ECHO" = "1"
                echo "$directory"
            end
            eval cd $directory
        end
      '';
      description = "Zoxide jump(first) with git branch in path";
    };
    _toggle_flag = {
      body = ''
        set -l flag_line $argv[1]
        set -l flag_file $argv[2]

        if grep --quiet "$flag_line" "$flag_file"
            set flag_value (grep "$flag_line" "$flag_file" | awk '{print $4}')

            if test "$flag_value" = "1"
                sed -i -e "s:$flag_line 1:$flag_line 0:" "$flag_file"
                echo "$flag_line toggled: 1 -> 0"
            else
                sed -i -e "s:$flag_line 0:$flag_line 1:" "$flag_file"
                echo "$flag_line toggled: 0 -> 1"
            end
        else
            echo "$flag_line 1" >> "$flag_file"
            echo "$flag_line appended: 1"
        end
      '';
    };
    toggle-conda = ''
      _toggle_flag "set -x FLAG_CONDA" ~/.private.fish
    '';
    fish_prompt = {
      description = "Fish simple prompt";
      body = ''
        if not set -q VIRTUAL_ENV_DISABLE_PROMPT
          set -g VIRTUAL_ENV_DISABLE_PROMPT true
        end
        ## START
        set_color $fish_color_cwd
        printf '%s' (prompt_pwd)
        set_color normal
        ## git branch
        set_color yellow
        printf '%s' (fish_git_prompt)
        set_color normal

        # Line 2
        echo
        if test -n "$VIRTUAL_ENV"
        printf "(%s) " (set_color blue)(basename $VIRTUAL_ENV)(set_color normal)
        end
        printf '↪ '
        set_color normal
      '';
    };
    cd-gitroot = {
      body = ''
        argparse -n cd-gitroot 'h/help' -- $argv
        or return 1

        if set -lq _flag_h
        _cd-gitroot_print_help
        return
        end

        if not git rev-parse --is-inside-work-tree > /dev/null 2>&1
        _cd-gitroot_print_error 'Not in a git repository'
        return 2
        end

        set -l root_path (git rev-parse --show-toplevel)
        set -l relative_path $argv[1]

        if test -z "$relative_path"
        cd -- $root_path
        else
        cd -- $root_path/$relative_path
        end
        end

        function _cd-gitroot_print_help
        echo 'Usage: cd-gitroot [OPTION] [PATH]
        Change directory to current git repository root directory.
        If PATH is specified, change directory to PATH instead of it.
        PATH is treated relative path in git root directory.

        -h, --help    display this help and exit'

        end

        function _cd-gitroot_print_error
        echo "cd-gitroot: $argv
        Try '-h' or '--help' option for more information." 1>&2
      '';
      description = "Cd into git root";
    };
    resort-fish-paths = {
      description = "reverse fish paths";
      body = ''
        set --local to_prepend

        # Iterate in reverse order so that once we prepend the paths they'll be in
        # the correct order.
        for i in (seq (count $PATH) -1 1)
        switch $PATH[$i]
            case "/nix/store/*"
                set --prepend to_prepend $i
        end
        end

        if test (count $to_prepend) -gt 0
        # Note: `$to_prepend` is an array so this gets expanded out to
        # `$PATH[$to_prepend[1]] $PATH[$to_prepend[2]] ...`.
        fish_add_path --global --move --path $PATH[$to_prepend]
        end
      '';
    };
  };
}
