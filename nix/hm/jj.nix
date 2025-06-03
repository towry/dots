# https://raw.githubusercontent.com/bnjmnt4n/system/refs/heads/main/home/shared/jujutsu.nix
{
  config,
  # lib,
  pkgs,
  ...
}:
let
  gitCfg = config.programs.git.extraConfig;
  bashScriptsDir = "${config.home.homeDirectory}/.local/bash/scripts";
in
{
  home.packages = [
    # pkgs.diffedit3
    pkgs.gg-jj
  ];
  programs.fish.shellAliases = {
    jl = "jj log -n 8";
    j = "jj";
    jj-mega-add = "jj-mega-merge -t m-m -f";
    jj-mega-rm = "jj-mega-merge -t m-m --remove";
    jj-sq-on = "bash ${bashScriptsDir}/jj-split-on-bookmark.sh -ai";
  };
  programs.jujutsu = {
    # use master version
    # package = pkgs-edge.jujutsu;
    enable = true;
    settings = {
      user = {
        name = gitCfg.user.name;
        email = gitCfg.user.email;
      };
      repo.github-url = "";
      core = {
        fsmonitor = "watchman";
        watchman.register-snapshot-trigger = true;
      };
      snapshot = {
        auto-update-stale = true;
        max-new-file-size = "1MiB";
      };
      git = {
        write-change-id-header = true;
        auto-local-bookmark = false;
        fetch = [
          "origin"
        ];
        push = "origin";
        push-bookmark-prefix = "towry/jj-";
        private-commits = "description(glob:'wip:*') | description(glob:'private:*') | description(glob:'WIP:*')";
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
        wip = [
          "commit"
          "-i"
          "--message"
          "WIP: empty message"
        ];
        wk = [ "workspace" ];
        df = [ "diff" ];
        sync-delete-bookmarks = [
          "git"
          "push"
          "--deleted"
        ];
        drop = [
          "abandon"
          "--retain-bookmarks"
          "--restore-descendants"
        ];
        mega-heads = [
          "log"
          "-r"
          "m-m-"
          "--no-graph"
        ];
        bt = [
          "bookmark"
          "list"
          "--tracked"
          "--sort"
          "committer-date-"
        ];
        bl = [
          "bookmark"
          "list"
          "--sort"
          "committer-date-"
        ];
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
        ls = [
          "log"
          "-r"
          "stack(@)"
        ];
        lmain = [
          "log"
          "-r"
          "(main..@):: | (main..@)-"
        ];
        dup = [
          "duplicate"
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
        # move bookmark to next node.
        mv-next = [
          "util"
          "exec"
          "--"
          "bash"
          "-c"
          ''
            #!/usr/bin/env bash
            set -euo pipefail

            bookmark=""

            while [[ $# -gt 0 ]]; do
              case "$1" in
                *)
                  bookmark="$1"
                  ;;
              esac
              shift || true
            done

            if [[ -z "$bookmark" ]]; then
              echo "Missing bookmark name"
              exit 1
            fi

            # source the jj-util.sh to use the functions
            source ${bashScriptsDir}/jj-util.sh

            next_changeid=$(__jj_util_get_next_changeid "$bookmark")
            if [[ $? -ne 0 ]]; then
              exit 1
            fi

            if [[ -n "$next_changeid" ]]; then
              # echo "jj bookmark move $bookmark --to $next_changeid"
              jj bookmark move "$bookmark" --to "$next_changeid"
            else
              echo "No next node found"
              exit 1
            fi
          ''
          ""
        ];
        ai-ci = [
          "util"
          "exec"
          "--"
          "bash"
          "-c"
          ''
            #!/usr/bin/env bash
            set -euo pipefail

            # Get the bash scripts directory
            bashScriptsDir="$HOME/.local/bash/scripts"

            if [[ $# -eq 0 ]]; then
              # No revision provided - create interactive commit first
              echo "No revision provided. Creating interactive commit..."

              # Run interactive commit (let it be truly interactive)
              if ! jj commit -m 'WIP: empty message' --color=never --no-pager -i; then
                exit_code=$?
                echo "Interactive commit failed or was cancelled" >&2
                exit $exit_code
              fi

              # Now get the status output to extract parent commit ID
              output=$(jj status --color=never --no-pager 2>&1)

              # Extract the parent commit ID from the output
              # Looking for pattern like: "Parent commit (@-): pknnznu 1c577a2 (empty) WIP: empty message"
              rev=$(echo "$output" | grep -E "Parent commit.*:" | sed -E 's/Parent commit \(@-\): ([a-z0-9]+) .*/\1/')

              if [[ -z "$rev" ]]; then
                echo "Error: Could not extract parent commit ID from jj output" >&2
                echo "Output was: $output" >&2
                exit 1
              fi

              echo "[AI] Using rev: $rev"
            else
              # Revision provided as argument
              rev="$1"
            fi

            # Generate commit message using aichat with jj context and apply it
            "$bashScriptsDir/jj-commit-context.sh" "$rev" | \
            aichat --role git-commit -S | \
            "$bashScriptsDir/jj-ai-commit.sh" "$rev"
          ''
          ""
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
        down = [
          "git"
          "fetch"
        ];
        abs = [
          "absorb"
        ];
        rb = [
          "rebase"
          "--skip-emptied"
        ];
        ds = [
          "desc"
        ];
        des-megamerge = [
          "describe"
          "-m"
          "private: megamerge"
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
          "-u"
        ];
        unsq = [
          "squash"
          "--restore-descendants"
        ];
        mcon = [
          "split"
          "-i"
          "-d"
        ];
        sqto = [
          "squash"
          "-k"
          "-u"
          "-i"
          "--to"
        ];
        tree = [
          "util"
          "exec"
          "--"
          "bash"
          "-c"
          ''
            #!/usr/bin/env bash
            set -euo pipefail
            if [ $# -gt 0 ]; then
              jj log -r "stack($1)"
            else
              jj log -r "stack(@)"
            fi
          ''
          ""
        ];
        mvc = [
          "squash"
          "-k"
          "-u"
        ];
        push = [
          "util"
          "exec"
          "--"
          "bash"
          "-c"
          ''
            #!/usr/bin/env bash
            set -euo pipefail
            if [[ $# -eq 0 ]]; then
              echo "jj git push"
              jj git push
            elif [[ $# -eq 1 ]]; then
              echo "jj git push --allow-new -b $1"
              jj git push --allow-new -b "$1"
            else
              cmd=(jj git push)
              for b in "$@"; do
                cmd+=("-b" "''$b")
              done
              echo "$cmd"
              eval "$cmd"
            fi
          ''
          ""
        ];
        # create new rev from bookmark and move the bookmark to the new rev.
        # 1 accept a bookmark name as argument
        # 2 create a new rev from the bookmark, jj new --from <bookmark>
        # 3 move the bookmark to the new rev, jj bookmark move <bookmark> --to <new-rev>
        # NOTE: log each command with echo
        nb = [
          "util"
          "exec"
          "--"
          "bash"
          "-c"
          ''
            #!/usr/bin/env bash
            set -euo pipefail

            msg=""
            bookmark=""

            while [[ $# -gt 0 ]]; do
              case "$1" in
                -m)
                  shift
                  msg="$1"
                  ;;
                *)
                  bookmark="$1"
                  ;;
              esac
              shift || true
            done

            if [[ -z "$bookmark" ]]; then
              echo "缺少 bookmark 名称"
              exit 1
            fi

            if [[ -n "$msg" ]]; then
              echo "jj new --no-edit -r $bookmark --message \"$msg\""
              output=$(jj new --no-edit -r "$bookmark" --message "$msg" 2>&1)
            else
              echo "jj new --no-edit -r $bookmark -m \"WIP: empty message\""
              output=$(jj new --no-edit -r "$bookmark" -m "WIP: empty message" 2>&1)
            fi

            rev=$(echo "$output" | grep -Eo 'Created new commit [a-z0-9]+' | sed 's/Created new commit //')

            if [[ -z "$rev" ]]; then
              echo "无法从 jj new 输出中提取 revision id: $output"
              exit 1
            fi

            echo "jj bookmark move $bookmark --to $rev"
            jj bookmark move "$bookmark" --to "$rev"
          ''
          ""
        ];
        create = [
          "new"
          "--no-edit"
        ];
        new-after = [
          "new"
          "--no-edit"
          "-A"
        ];
        new-before = [
          "new"
          "--no-edit"
          "-B"
        ];
        new-master = [
          "new"
          "--no-edit"
          "-r"
          "master@origin"
        ];
        new-main = [
          "new"
          "--no-edit"
          "-r"
          "main@origin"
        ];
        rv = [
          "resolve"
        ];
        # resolve conflicts with nvim3way tool
        mt = [
          "resolve"
          "--tool"
          "nvim3way"
        ];
        mt-ours = [
          "resolve"
          "--tool"
          ":ours"
        ];
        mt-theirs = [
          "resolve"
          "--tool"
          ":theirs"
        ];
        lo = [
          "log"
          "--no-graph"
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
        diff-formatter = ":git";
        diff-editor = ":builtin";
        # diff-editor = "diffedit3";
        # pager = "less -FRX";
        pager = "delta";
      };
      signing = {
        backend = "ssh";
        key = "~/.ssh/id_ed25519.pub";
        behavior = "own";
      };
      # used by the builtin utils.
      templates = {
        log = "log_compact";
        log_node = ''
          coalesce(
            if(!self, label("elided", "⇋")),
            if(current_working_copy, label("working_copy", "@")),
            if(immutable, label("immutable", "◆")),
            if(conflict, label("conflict", "×")),
            if(is_wip_commit_description(description), label("wip", "○")),
            if(empty, "◌"),
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
        "m-m" = "description('private: megamerge')";

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
        "diff_xy(x, y)" = "..x & mutable() ~ ..y & mutable()";
        "not_included(x, y)" = "x..ancestors(y, 1)";
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
      fix.tools = {
        ncu-sandbox = {
          command = [
            "qx"
            "ncu"
            "sandbox"
          ];
          patterns = [
            "package.json"
          ];
          enabled = false;
        };
        ncu-latest = {
          command = [
            "qx"
            "ncu"
            "latest"
          ];
          patterns = [
            "package.json"
          ];
        };
      };
    };
  };
  home.file = {
    ".config/fish/functions/jj-mega-merge.fish" = {
      source = ../../conf/fish/funcs/jj-mega-merge.fish;
    };
    ".config/fish/functions/jj-fork-main.fish" = {
      source = ../../conf/fish/funcs/jj-fork-main.fish;
    };
    ".config/fish/functions/jj-mega-up.fish" = {
      source = ../../conf/fish/funcs/jj-mega-up.fish;
    };
    ".config/fish/functions/jj-fork-master.fish" = {
      source = ../../conf/fish/funcs/jj-fork-master.fish;
    };
    ".config/fish/functions/_fzf-jj-revs.fish" = {
      source = ../../conf/fish/funcs/_fzf-jj-revs.fish;
    };
    ".config/fish/functions/_fzf-jj-bookmarks.fish" = {
      source = ../../conf/fish/funcs/_fzf-jj-bookmarks.fish;
    };
    ".config/fish/functions/jj-review.fish" = {
      source = ../../conf/fish/funcs/jj-review.fish;
    };
  };
}
