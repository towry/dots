# https://raw.githubusercontent.com/bnjmnt4n/system/refs/heads/main/home/shared/jujutsu.nix
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
    pkgs.gg-jj
  ];
  programs.fish.shellAliases = {
    jl = "jj log -n 8";
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
      repo.github-url = "";
      core = {
        fsmonitor = "watchman";
        watchman.register_snapshot_trigger = true;
      };
      snapshot = {
        auto-update-stale = true;
        max-new-file-size = "1MiB";
      };
      git = {
        subprocess = true;
        fetch = [
          "origin"
        ];

        push = "origin";
        push-bookmark-prefix = "towry-push-";
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
        nvim3way = {
          program = "nvim";
          diff-expected-exit-codes = [
            0
            1
          ];
          merge-tool-edits-conflict-markers = true;
          merge-args = [
            "-c"
            "DiffConflicts"
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
        drop = [ "abandon" ];
        lmaster = [
          "log"
          "-r"
          "(master..@):: | (master..@)-"
        ];
        lr = [
          "log"
          "-r"
          "working()"
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
        ff = [
          "git"
          "fetch"
        ];
        download = [
          "git"
          "fetch"
        ];
        abs = [
          "absorb"
        ];
        rb = [
          "rebase"
        ];
        ds = [
          "desc"
        ];
        l = [
          "log"
          "-r"
          "reachable(@, mutable() | parents(mutable()))"
          "-n"
          "8"
        ];
        sq = [
          "squash"
        ];
        mv-changes = [
          "squash"
          "-k"
          "-u"
        ];
        new-node = [
          "new"
          "--no-edit"
        ];
        usq = [
          "unsquash"
        ];
      };
      ui = {
        conflict-marker-style = "git";
        log-word-wrap = false;
        editor = [
          "nvim"
          "--cmd"
          "let g:flatten_wait=1"
        ];
        streampager = {
          interface = "full-screen-clear-output";
          wrapping = "none";
        };

        default-command = [
          "status"
          # "log"
          # "--no-pager"
          # "-n"
          # "5"
        ];
        # diff.tool = [
        #   "${lib.getExe pkgs.difftastic}"
        #   "--color=always"
        #   "$left"
        #   "$right"
        # ];
        ### use git diff as default diff tool
        diff.format = "git";
        diff-editor = ":builtin";
        # diff-editor = "diffedit3";
        # pager = "less -FRX";
        pager = "delta";
      };
      signing = {
        backend = "ssh";
        key = "~/.ssh/id_ed25519.pub";
        sign-all = true;
      };
      templates = {
        log = "log_compact";
        log_node = ''
          coalesce(
            if(!self, label("elided", "⇋")),
            if(current_working_copy, label("working_copy", "@")),
            if(immutable, label("immutable", "◆")),
            if(conflict, label("conflict", "×")),
            if(is_wip_commit_description(description), label("wip", "○")),
            "○"
          )
        '';
        commit_summary = "format_commit_summary(self, bookmarks, tags)";
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
      template-aliases = {
        "hyperlink(url, text)" = ''
          raw_escape_sequence("\e]8;;" ++ url ++ "\e\\") ++
          text ++
          raw_escape_sequence("\e]8;;\e\\")
        '';
        "is_wip_commit_description(description)" = ''
          !description ||
          description.first_line().lower().starts_with("wip:") ||
          description.first_line().lower() == "wip"
        '';
        "format_short_id(id)" = "id.shortest(7)";
        "format_timestamp(timestamp)" = ''
          if(
            timestamp.before("1 month ago"),
            timestamp.format("%b %d %Y %H:%M"),
            timestamp.ago()
          )
        '';
        "format_short_change_id_with_hidden_and_divergent_info(commit)" = ''
          label(
            coalesce(
              if(commit.current_working_copy(), "working_copy"),
              if(commit.contained_in("trunk()"), "trunk"),
              if(commit.immutable(), "immutable"),
              if(commit.conflict(), "conflict"),
              if(is_wip_commit_description(commit.description()), "wip"),
            ),
            if(commit.hidden(),
              label("hidden",
                format_short_change_id(commit.change_id()) ++ " hidden"
              ),
              label(if(commit.divergent(), "divergent"),
                format_short_change_id(commit.change_id()) ++ if(commit.divergent(), "??")
              )
            )
          )
        '';
        "format_root_commit(root)" = ''
          separate(" ",
            label("immutable", format_short_change_id(root.change_id())),
            format_short_commit_id(root.commit_id()),
            label("root", "root()"),
            root.bookmarks()
          ) ++ "\n"
        '';
        "format_commit_description(commit)" = ''
          separate(" ",
            if(commit.empty(),
              label(
                separate(" ",
                  if(commit.immutable(), "immutable"),
                  if(commit.hidden(), "hidden"),
                  if(commit.contained_in("trunk()"), "trunk"),
                  if(is_wip_commit_description(commit.description()), "wip"),
                  "empty",
                  "description",
                ),
                "(empty)"
              )),
            if(commit.description(),
              label(
                separate(" ",
                  if(commit.contained_in("trunk()"), "trunk"),
                  if(is_wip_commit_description(commit.description()), "wip")),
                commit.description().first_line()),
              label(
                separate(" ",
                  if(commit.contained_in("trunk()"), "trunk"),
                  "wip",
                  if(commit.empty(), "empty")),
                description_placeholder))
          )
        '';
        "format_commit_id(commit)" = ''
          if(config("repo.github-url").as_string() && commit.contained_in("..remote_bookmarks(remote=exact:'origin')"),
            hyperlink(
              concat(config("repo.github-url").as_string(), "/commit/", commit.commit_id()),
              format_short_commit_id(commit.commit_id()),
            ),
            format_short_commit_id(commit.commit_id()),
          )
        '';
        "format_long_commit_id(commit)" = ''
          if(config("repo.github-url").as_string() && commit.contained_in("..remote_bookmarks(remote=exact:'origin')"),
            hyperlink(
              concat(config("repo.github-url").as_string(), "/commit/", commit.commit_id()),
              commit.commit_id(),
            ),
            commit.commit_id(),
          )
        '';
        "format_ref_targets(ref)" = ''
          if(ref.conflict(),
            separate("\n",
              " " ++ label("conflict", "(conflicted)") ++ ":",
              ref.removed_targets().map(|c| "  - " ++ format_commit_summary(c)).join("\n"),
              ref.added_targets().map(|c| "  + " ++ format_commit_summary(c)).join("\n"),
            ),
            ": " ++ format_commit_summary(ref.normal_target()),
          )
        '';
        "format_commit_summary(commit)" = ''
          separate(" ",
            format_short_change_id_with_hidden_and_divergent_info(commit),
            format_commit_id(commit),
            separate(" ",
              if(commit.conflict(), label("conflict", "(conflict)")),
              format_commit_description(commit),
            ),
          )
        '';
        "format_commit_summary(commit, bookmarks, tags)" = ''
          separate(" ",
            format_short_change_id_with_hidden_and_divergent_info(commit),
            format_commit_id(commit),
            separate(commit_summary_separator,
              format_commit_bookmarks(bookmarks),
              format_commit_tags(tags),
              separate(" ",
                if(commit.conflict(), label("conflict", "(conflict)")),
                format_commit_description(commit),
              ),
            ),
          )
        '';
        log_oneline = ''
          if(root,
            format_root_commit(self),
            label(if(current_working_copy, "working_copy"),
              separate(" ",
                format_short_change_id_with_hidden_and_divergent_info(self),
                format_commit_id(self),
                if(author.email(), author.email().local(), email_placeholder),
                format_timestamp(committer.timestamp()),
                format_commit_bookmarks(bookmarks),
                format_commit_tags(tags),
                working_copies,
                if(git_head, label("git_head", "git_head()")),
                if(conflict, label("conflict", "conflict")),
                format_commit_description(self),
              ) ++ "\n",
            )
          )
        '';
        log_compact_no_summary = ''
          if(root,
            format_root_commit(self),
            label(if(current_working_copy, "working_copy"),
              concat(
                separate(" ",
                  format_short_change_id_with_hidden_and_divergent_info(self),
                  format_commit_id(self),
                  format_short_signature(author),
                  format_timestamp(committer.timestamp()),
                  format_commit_bookmarks(bookmarks),
                  format_commit_tags(tags),
                  working_copies,
                  if(git_head, label("git_head", "git_head()")),
                  if(conflict, label("conflict", "conflict")),
                ) ++ "\n",
                format_commit_description(self) ++ "\n",
              ),
            )
          )
        '';
        log_compact = ''
          if(root,
            format_root_commit(self),
            label(if(current_working_copy, "working_copy"),
              concat(
                separate(" ",
                  format_short_change_id_with_hidden_and_divergent_info(self),
                  format_commit_id(self),
                  format_short_signature(author),
                  format_timestamp(committer.timestamp()),
                  format_commit_bookmarks(bookmarks),
                  format_commit_tags(tags),
                  working_copies,
                  if(git_head, label("git_head", "git_head()")),
                  if(conflict, label("conflict", "conflict")),
                ) ++ "\n",
                format_commit_description(self) ++ "\n",
                if(!empty &&
                  (is_wip_commit_description(description) || current_working_copy),
                  diff.summary()
                ),
              ),
            )
          )
        '';
        log_detailed = ''
          concat(
            "Commit ID: " ++ format_long_commit_id(self) ++ "\n",
            "Change ID: " ++ change_id ++ "\n",
            surround("Bookmarks: ", "\n",
              separate(" ", format_commit_bookmarks(local_bookmarks), format_commit_bookmarks(remote_bookmarks))),
            surround("Tags     : ", "\n", format_commit_tags(tags)),
            "Author   : " ++ format_detailed_signature(author) ++ "\n",
            "Committer: " ++ format_detailed_signature(committer)  ++ "\n",
            if(signature, "Signature: " ++ format_detailed_cryptographic_signature(signature) ++ "\n"),
            "\n",
            indent("    ",
              coalesce(description, label(if(empty, "empty"), description_placeholder) ++ "\n")),
            "\n",
          )
        '';
        # ----- TODO: unstable funcs
        "format_commit_bookmarks(bookmarks)" = ''
          if(config("repo.github-url").as_string(),
            bookmarks.map(
              |bookmark| if(
                bookmark.remote() == "origin" || bookmark.remote() == "",
                hyperlink(concat(config("repo.github-url").as_string(), "/tree/", bookmark.name()), bookmark),
                bookmark
              )
            ),
            bookmarks
          )
        '';
        "format_commit_tags(tags)" = ''
          if(config("repo.github-url").as_string(),
            tags.map(
              |tag| if(
                tag.remote() == "origin" || tag.remote() == "",
                hyperlink(concat(config("repo.github-url").as_string(), "/releases/tag/", tag.name()), tag),
                tag
              )
            ),
            tags
          )
        '';
      };
      revset-aliases = {
        "at" = "@";
        "AT" = "@";

        "new_visible_commits(op)" =
          "at_operation(@-, at_operation(op, visible_heads()))..at_operation(op, visible_heads())";
        "new_hidden_commits(op)" =
          "at_operation(op, visible_heads())..at_operation(@-, at_operation(op, visible_heads()))";

        "base()" = "roots(roots(trunk()..@)-)";
        "tree(x)" = "reachable(x, ~ ::trunk())";
        "stack(x)" = "trunk()..x";
        "overview()" = "@ | ancestors(remote_bookmarks(), 2) | trunk() | root()";
        "my_unmerged()" = "mine() ~ ::trunk()";
        "my_unmerged_remote()" = "mine() ~ ::trunk() & remote_bookmarks()";
        "not_pushed()" = "remote_bookmarks()..";
        "archived()" = "(mine() & description(regex:'^archive($|:)'))::";
        "unarchived(x)" = "x ~ archived()";
        "diverge(x)" = "fork_point(x)::x";
        # "working()" = "visible_heads() | ancestors(visible_heads(), 2)";
        "working()" = "ancestors(visible_heads() & mutable(), 2)";
      };
      colors = {
        git_head = {
          bold = false;
          italic = true;
        };
        bookmarks = {
          bold = true;
          italic = true;
          underline = false;
          fg = "magenta";
        };
        commit_id = "yellow";
        timestamp = "bright black";
        author = {
          fg = "bright black";
          italic = true;
        };
        change_id = {
          bold = true;
          fg = "bright green";
          underline = true;
        };
        "diff modified" = {
          fg = "cyan";
          bold = true;
        };
      };
    };
  };
}
