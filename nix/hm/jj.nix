{
  config,
  lib,
  pkgs,
  ...
}:
let
  gitCfg = config.programs.git.extraConfig;
in
{
  home.packages = [
    # pkgs.diffedit3
  ];
  programs.fish.shellAliases = {
    jl = "jj log";
    j = "jj";
    jj-mv-work = "jj bookmark move --to @ towry/workspace";
    jj-up-work = "jj git push -b towry/workspace --allow-empty-description";
    jj-sync-work = "jj bookmark move --to @ towry/workspace && jj git push -b towry/workspace --allow-empty-description";
  };
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = gitCfg.user.name;
        email = gitCfg.user.email;
      };
      core = {
        fsmonitor = "watchman";
        watchman.register_snapshot_trigger = true;
      };
      snapshot = {
        auto-update-stale = true;
        max-new-file-size = "1MiB";
      };
      git = {
        fetch = [
          "origin"
        ];

        push = "origin";
        push-bookmark-prefix = "towry/";
      };
      merge-tools = {
        code = {
          program = "code";
          merge-tool-edits-conflict-markers = true;
          merge-args = [
            "--wait"
            "--merge"
            "$output"
            "$base"
            "$left"
            "$right"
          ];
        };
        nvim2way = {
          program = "nvim";
          merge-tool-edits-conflict-markers = true;
          merge-args = [
            "-c"
            "let g:jj_diffconflicts_marker_length=$marker_length"
            "-c"
            "JJDiffConflicts!"
            "$output"
            "$base"
            "$left"
            "$right"
          ];
        };
      };
      format.tree-level-conflicts = true;
      aliases = {
        df = [ "diff" ];
        lmaster = [
          "log"
          "-r"
          "(master..@):: | (master..@)-"
        ];
        lmain = [
          "log"
          "-r"
          "(main..@):: | (main..@)-"
        ];
        mv = [
          "bookmark"
          "move"
        ];
        tug = [
          "bookmark"
          "move"
          "--to"
          "@-"
        ];
        mv-back = [
          "bookmark"
          "move"
          "--allow-backwards"
        ];
        discard-changes = [
          "restore"
        ];
        amend = [
          "squash"
        ];
        gp = [
          "git"
          "push"
        ];
        # push bookmarks that point to the rev
        gpr = [
          "git"
          "push"
          "-r"
        ];
        # push commits by creating bookmark based on it's changeid.
        gpc = [
          "git"
          "push"
          "-c"
        ];
        gp-new = [
          "git"
          "push"
          "--allow-new"
        ];
        blame = [
          "file"
          "annotate"
        ];
        fb = [
          "git"
          "fetch"
          "-b"
        ];
        download = [
          "git"
          "fetch"
        ];
        rb = [
          "rebase"
          "-d"
        ];
        ds = [
          "desc"
          "-m"
        ];
        l = [
          "log"
          "-r"
          "reachable(@, mutable() | parents(mutable()))"
          "-n"
          "8"
        ];
      };
      ui = {
        editor = "nvim";

        default-command = [
          "status"
        ];
        diff.tool = [
          "${lib.getExe pkgs.difftastic}"
          "--color=always"
          "$left"
          "$right"
        ];
        diff-editor = ":builtin";
        # diff-editor = "diffedit3";
        pager = "less -FRX";
      };
      signing = {
        backend = "ssh";
        key = "~/.ssh/id_ed25519.pub";
        sign-all = true;
      };
      templates = {
        draft_commit_description = ''
          concat(
            description,
            indent("JJ: ", concat(
              "\n",
              "Change summary:\n",
              indent("     ", diff.summary()),
              "\n",
              "Full change:\n",
              indent("     ", diff.git()),
            )),
          )
        '';
      };
      colors = {
        git_head = {
          fg = "black";
          bg = "white";
          bold = true;
        };
        bookmarks = {
          bold = true;
          underline = true;
          fg = "magenta";
        };
      };
    };
  };
}
