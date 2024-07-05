{
  pkgs,
  lib,
  ...
}: let
  enable_delta = true;
in {
  programs.git = {
    enable = true;

    package = pkgs.git.override {
      guiSupport = false;
    };

    aliases = {
      co = "checkout";
      ad = "add";
      ada = "add -A";
      sw = "switch";
      ca = "commit --amend --no-edit";
      wip = ''
        !sh -c 'if [[ "$(git log -1 --pretty=%B)" != "[WIP]:"* ]]; then \
                       git commit -m "wip: $(date)"; \
                   else \
                       git commit --amend -m "wip: $(date)"; \
                   fi'
      '';
      st = "status";
      add-note = ''branch --edit-description'';
      note = ''!git config --get branch.$(git rev-parse --abbrev-ref HEAD).description'';
      sh = "show";
      default-branch = "!git symbolic-ref refs/remotes/origin/HEAD | cut -d'/' -f4";
      ss = ''!f() { if [ $# -eq 0 ]; then git stash list; else git stash $@; fi; }; f'';
      up = ''!git push -u origin HEAD:$(git rev-parse --abbrev-ref HEAD)'';
      fu = ''!git status --short && git push --force-with-lease --progress -u origin HEAD:$(git rev-parse --abbrev-ref HEAD)'';
      pr = "pull --rebase";
      pp = ''!git pull --ff origin $(git rev-parse --abbrev-ref HEAD)'';
      ps = ''!git pull --autostash --no-tags origin $(git rev-parse --abbrev-ref HEAD)'';
      pf = ''!git pull --ff-only $(git-rev-parse --abbrev-ref HEAD)'';
      fa = "fetch --all";
      fp = "fetch --all -p";
      # fz = "fuzzy";
      ff = "fetch";
      mg = "merge --no-ff";
      kill-merge = "merge --abort";
      br = "branch";
      br-gone = "!git branch -vv | grep -F ': gone]' | awk '{ print $1 }' | grep -vF '*'";
      br-prune-gone = "!git for-each-ref --format '%(refname:short) %(upstream:track)' | awk '$2 == \"[gone]\" {print $1}' | xargs -r git branch -D";
      df = "diff";
      dt = "difftool";
      dfc = "diff --cached";
      dfh = "diff HEAD";
      dfs = "diff --stat";
      wc = "whatchanged";
      wc1 = "whatchanged -1";
      wcl = "whatchanged -3";
      cat = "cat-file -p";
      undo = "reset --soft";
      reset-remote = "!git reset --hard origin/$(git rev-parse --abbrev-ref HEAD)";
      unstage = "restore --staged";
      changed-files = "!sh -c 'default_branch=master; if git rev-parse --verify master >/dev/null 2>/dev/null; then default_branch=master; elif git rev-parse --verify main >/dev/null 2>/dev/null; then default_branch=main; else echo \"Neither master nor main branches found.\"; exit 1; fi; git fetch origin $default_branch >/dev/null 2>&1; git diff --name-only origin/$default_branch...'";
      add-remote-branches = "remote set-branches --add";
      lg = "log --graph --pretty=format:'%Cred%h%Creset %s %C(white)%ad%Creset %C(yellow)%d%Creset %C(bold blue)<%an>%Creset' --date=short";
      lg1 = "log --oneline --date=relative --pretty=format:'%Cred%h%Creset %s %C(white)%ad%Creset %C(yellow)%d%Creset %C(bold blue)<%an>%Creset'";
      lt = "log --oneline --date=relative -n3 --pretty=format:'%Cred%h%Creset %s %C(yellow)%d%Creset %C(bold blue)<%an>%Creset - %C(white)%ad%Creset'";
      yesterday = "log --since yesterday --until=midnight --color --graph \
            --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(blue)[%an]%Creset' \
            --abbrev-commit";
      clone1 = "clone --depth=1";
      des = "describe";
      wt = "worktree";
      mt = "mergetool";
      bi = "bisect";
      rp = "rev-parse";
      rl = "rev-list";
      rn = "name-rev";
      rb = "rebase";
      rbk = "rebase --skip";
      rbc = "rebase --continue";
      rba = "rebase --abort";
      "re3" = "rerere";
      latest-tag = "describe --tags";
      alias = "! git config --get-regexp '^alias\\.' | sed 's/^alias\\.//' | fzf";
      ignore = "!gi() { curl -sL https://www.gitignore.io/api/$@ ;}; gi";
      config-fetch-origin = ''config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"'';
      ahead = "rev-list --left-right --count";
      # commit convention
      it-wip = ''!f() { git commit -m \"wip: <😎> $([[ -z $@ ]] && date || echo $@ )\"; }; f'';
      it-fix = ''!f() { git commit -m "fixup: <🐞> $(echo $@)"; }; f'';
      it-fmt = ''!f() { git commit -m "style: <🎨> $(echo $@)"; }; f'';
      it-test = ''!f() { git commit -m "test: <🐛> $(echo $@)"; }; f'';
      it-ref = ''!f() { git commit -m "refactor: <🐭> $(echo $@)"; }; f'';
      it-doc = ''!f() { git commit -m "doc: <📚> $(echo $@)"; }; f'';
      "it-feat" = ''!f() { git commit -m "feat: <🐸> $(echo $@)"; }; f'';
      "it-perf" = ''!f() { git commit -m "perf: <⚡️> $(echo $@)"; }; f'';
      "it-chore" = ''!f() { git commit -m "chore: <🔨> $(echo $@)"; }; f'';
      it-revert = ''!f() { git commit -m "revert: <🔙> $(echo $@)"; }; f'';
      it-build = ''!f() { git commit -m "build: <🏗️> $(echo $@)"; }; f'';
      it-ci = ''!f() { git commit -m "ci: <👷> $(echo $@)"; }; f'';
      it-deps = ''!f() { git commit -m "deps: <📦> $(echo $@)"; }; f'';
      it-typo = ''!f() { git commit -m "typo: <🐛> $(echo $@)"; }; f'';
      it-rm = ''!f() { git commit -m "cleanup: <🗑️> $(echo $@)"; }; f'';
      it-omg = ''!f() { git commit -m "omg: <🤩> $(echo $@)"; }; f'';
    };

    extraConfig = {
      user = {
        name = "Towry Wang";
        email = "towry@users.noreply.github.com";
        username = "towry";
      };
      url = {
        # "ssh://".indexOf = "git://";
        "git@github.com:".insteadOf = "https://github.com";
      };
      core = {
        ignorecase = false;
        autocrlf = "input";
        pager = lib.mkForce (
          if enable_delta
          then "${pkgs.delta}/bin/delta"
          else "less"
        );
      };
      rerere = {
        enabled = true;
      };
      rebase = {
        autosquash = true;
        autoStash = true;
      };
      pull = {
        rebase = true;
        ff = ''only'';
      };
      push = {
        default = "simple";
        autoSetupRemote = true;
      };
      merge = {
        ff = ''only'';
        tool = "nvimtwoway";
        conflictstyle = "diff3";
        prompt = true;
      };
      diff = {
        colorMoved = "dimmed-zebra";
        algorithm = "histogram";
        compactionHeuristic = true;
      };
      mergetool = {
        keepBackup = false;
        nvimmerge = {
          cmd = ''nvim -d "$LOCAL" "$BASE" "$REMOTE" "$MERGED" -c "wincmd w" -c "wincmd J"'';
        };
        nvimtwoway = {
          cmd = ''nvim -c DiffConflicts "$MERGED" "$BASE" "$LOCAL" "$REMOTE"'';
        };
      };
      credential.helper = "store";
      color = {
        ui = true;
        branch = {
          current = "yellow reverse";
          local = "yellow";
          remote = "green";
        };
      };
      interactive = lib.mkIf enable_delta {diffFilter = "${pkgs.delta}/bin/delta --color-only";};
      advice = {
        detachedHead = true;
      };
    };

    delta = {
      enable = enable_delta;
      options = {
        kanagawa-style = {
          line-numbers-zero-style = ''blue'';
        };
        # allow easy copy
        keep-plus-minus-markers = false;
        syntax-theme = "kanagawa-dragon";
        file-decoration-style = "blue box";
        hunk-header-decoration-style = "blue ul";
        line-numbers = true;
        navigate = true;
        features = "diff-so-fancy kanagawa-style";
        hyperlinks = true;
      };
    };

    ignores = [
      ".DS_Store"
      ".direnv/"
      "Session.vim"
      ".pyo"
      "dist/"
      ".netrwhist"
      ".netrwhist~"
      "node_modules/"
      "result/"
      "target/"
    ];
  };
}
