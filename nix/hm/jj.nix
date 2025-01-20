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
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = gitCfg.user.name;
        email = gitCfg.user.email;
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
          "set"
          "--revision"
        ];
        gp = [
          "git"
          "push"
        ];
        ft = [
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
      };
      ui = {
        editor = "nvim";

        default-command = [
          "log"
          "-r"
          "reachable(@, mutable() | ~mutable())"
          "-n"
          "8"
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
