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
    pkgs.jjui
  ];
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
        auto-track = "glob:'**/*.*'";
      };
      git = {
        fetch = [
          "upstream"
          "origin"
        ];

        push = "origin";
        push-bookmark-prefix = "towry/";
      };
      merge-tools = {
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
          "reachable(@, mutable())"
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
        diff-editor = [
          "nvim"
          "-c"
          "DiffEditor $left $right $output"
        ];
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
        bookmarks = {
          bold = true;
          underline = true;
        };
      };
    };
  };
}
