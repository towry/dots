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
      aliases = {
        wip = [
          "commit"
          "-i"
          "--message"
          "WIP: empty message"
        ];
        wk = [ "workspace" ];
        df = [ "diff" ];
        df-names = [
          "diff"
          "--ignore-working-copy"
          "--no-pager"
          "--name-only"
          "-r"
        ];
        git-init = [
          "git"
          "init"
          "--colocate"
        ];
        git-diff = [
          "--no-pager"
          "diff"
          "--git"
        ];
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
        heads = [
          "log"
          "-r"
          "heads(@)"
          "--no-pager"
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
        mv-staging-to = [
          "mv"
          "pub/sandbox"
          "--to"
        ];
        tug = [
          "util"
          "exec"
          "--"
          "bash"
          "-c"
          ''
            #!/usr/bin/env bash
            set -euo pipefail

            # Source and run the jj-tug.sh script
            source ${bashScriptsDir}/jj-tug.sh
            main "$@"
          ''
          ""
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
        # descript existing commit, prefix with '[skip ci]' to skip gh CI.
        ds-skip-ci = [
          "util"
          "exec"
          "--"
          "bash"
          "-c"
          ''
            #!/usr/bin/env bash
            set -euo pipefail

            rev=""

            # Parse arguments
            while [[ $# -gt 0 ]]; do
              case "$1" in
                *)
                  rev="$1"
                  ;;
              esac
              shift || true
            done

            # Default to current revision if none provided
            if [[ -z "$rev" ]]; then
              rev="@"
            fi

            echo "[ds-skip-ci] Processing revision: $rev"

            # Get current description
            current_desc=$(jj log -r "$rev" --no-graph --color=never --template 'description' 2>/dev/null)

            if [[ -z "$current_desc" ]]; then
              echo "[ds-skip-ci] ERROR: Could not get description for revision $rev" >&2
              exit 1
            fi

            # Check if already has [skip ci] prefix
            if [[ "$current_desc" =~ ^\[skip\ ci\] ]]; then
              echo "[ds-skip-ci] Revision $rev already has [skip ci] prefix"
              echo "Current description: $current_desc"
              exit 0
            fi

            # Add [skip ci] prefix
            new_desc="[skip ci] $current_desc"

            echo "[ds-skip-ci] Updating description..."

            # Update the description
            if jj describe -r "$rev" -m "$new_desc" --color=never --no-pager; then
              echo "[ds-skip-ci] ✓ Successfully updated description for revision $rev"
            else
              echo "[ds-skip-ci] ERROR: Failed to update description for revision $rev" >&2
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

            # Parse arguments
            extra_context=""
            rev=""

            while [[ $# -gt 0 ]]; do
              case "$1" in
                -m)
                  shift
                  if [[ $# -eq 0 ]]; then
                    echo "[AI-CI] ERROR: -m flag requires a message argument" >&2
                    exit 1
                  fi
                  extra_context="$1"
                  echo "[AI-CI] Extra context provided: $extra_context"
                  ;;
                *)
                  if [[ -z "$rev" ]]; then
                    rev="$1"
                  else
                    echo "[AI-CI] ERROR: Unexpected argument: $1" >&2
                    echo "Usage: jj ai-ci [-m <extra_context>] [revision]" >&2
                    exit 1
                  fi
                  ;;
              esac
              shift
            done

            if [[ -z "$rev" ]]; then
              # No revision provided - create interactive commit first
              echo "[AI-CI] Step 1/4: No revision provided. Creating interactive commit..."

              # Run interactive commit (let it be truly interactive)
              if ! jj commit -m 'WIP: empty message' --color=never --no-pager -i; then
                exit_code=$?
                echo "[AI-CI] ERROR: Step 1/4 failed - Interactive commit failed or was cancelled (exit code: $exit_code)" >&2
                exit $exit_code
              fi
              echo "[AI-CI] Step 1/4: ✓ Interactive commit successful"

              echo "[AI-CI] Step 2/4: Extracting parent commit ID..."
              # Now get the status output to extract parent commit ID
              output=$(jj status --color=never --no-pager 2>&1)

              # Extract the parent commit ID from the output
              # Looking for pattern like: "Parent commit (@-): pknnznu 1c577a2 (empty) WIP: empty message"
              rev=$(echo "$output" | grep -E "Parent commit.*:" | sed -E 's/Parent commit \(@-\): ([a-z0-9]+) .*/\1/')

              if [[ -z "$rev" ]]; then
                echo "[AI-CI] ERROR: Step 2/4 failed - Could not extract parent commit ID from jj output" >&2
                echo "Output was: $output" >&2
                exit 1
              fi

              echo "[AI-CI] Step 2/4: ✓ Using rev: $rev"
            else
              # Revision provided as argument
              echo "[AI-CI] Step 1/4: ✓ Using provided revision: $rev"
            fi

            echo "[AI-CI] Step 3/4: Generating commit context..."
            # Generate commit context and check if successful
            # Don't capture stderr so we can see debug messages
            if context_output=$("$bashScriptsDir/jj-commit-context.sh" "$rev"); then
              echo "[AI-CI] Step 3/4: ✓ Commit context generated successfully"
            else
              context_exit_code=$?
              echo "[AI-CI] ERROR: Step 3/4 failed - jj-commit-context.sh failed (exit code: $context_exit_code)" >&2
              exit $context_exit_code
            fi

            echo "[AI-CI] Step 4/4: Generating AI commit message and applying..."

            # Prepare input for aichat - combine context with extra context if provided
            ai_input="$context_output"
            if [[ -n "$extra_context" ]]; then
              ai_input=$(printf "%s\n\nAdditional context: %s" "$context_output" "$extra_context")
              echo "[AI-CI] Including extra context in AI generation"
            fi

            # Generate commit message using aichat with jj context and apply it
            if ! ai_output=$(echo "$ai_input" | aichat --role git-commit -S -c 2>&1); then
              aichat_exit_code=$?
              echo "[AI-CI] ERROR: Step 4/4 failed - aichat failed (exit code: $aichat_exit_code)" >&2
              echo "aichat output: $ai_output" >&2
              exit $aichat_exit_code
            fi
            echo "[AI-CI] Step 4/4: ✓ AI commit message generated"

            echo "[AI-CI] Step 5/5: Applying commit message..."
            if ! echo "$ai_output" | "$bashScriptsDir/jj-ai-commit.sh" "$rev"; then
              apply_exit_code=$?
              echo "[AI-CI] ERROR: Step 5/5 failed - jj-ai-commit.sh failed (exit code: $apply_exit_code)" >&2
              echo "AI message was: $ai_output" >&2
              exit $apply_exit_code
            fi
            echo "[AI-CI] Step 5/5: ✓ Commit message applied successfully"
            echo "[AI-CI] ✓ AI commit process completed successfully!"
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
        merge = [
          "util"
          "exec"
          "--"
          "bash"
          "-c"
          ''
            #!/usr/bin/env bash
            set -euo pipefail

            # Source and run the jj-merge.sh script
            exec bash ${bashScriptsDir}/jj-merge.sh "$@"
          ''
          ""
        ];
        merge-staging = [
          "merge"
          "pub/sandbox"
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
          "util"
          "exec"
          "--"
          "bash"
          "-c"
          ''
            #!/usr/bin/env bash
            set -euo pipefail

            jj git fetch --ignore-working-copy && echo "" && jj log -r "heads(@-::) ~ empty()" --ignore-working-copy --no-pager
          ''
          ""
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
        unsq = [
          "squash"
          "--restore-descendants"
        ];
        split-on = [
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
        sq = [
          "squash"
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
        push-staging = [
          "push"
          # TODO: get staging bookmark from config
          "pub/sandbox"
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
        # resolve conflicts with nvim3way tool, for simple 2 sides
        mt = [
          "resolve"
          "--tool"
          "nvim3way"
        ];
        # resolve conflicts with nvim2way tool, for jj more than 3 sides
        mt3 = [
          "resolve"
          "--tool"
          "nvim2way"
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
          "-r"
          "..@"
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
          # "status"
          "log"
          "--no-pager"
          "-n"
          "4"
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
        git_push_bookmark = ''"towry/jj-" ++ change_id.short()'';
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

        # Override immutable_heads to include pub/sandbox bookmark and commits older than 1 day
        ## description(regex:'^\\[JJ\\]:')
        ## added above make it slow
        "immutable_heads()" = "builtin_immutable_heads() | present(pub/sandbox)";

        "new_visible_commits(op)" =
          "at_operation(@-, at_operation(op, visible_heads()))..at_operation(op, visible_heads())";
        "new_hidden_commits(op)" =
          "at_operation(op, visible_heads())..at_operation(@-, at_operation(op, visible_heads()))";

        "base()" = "roots(roots(trunk()..@)-)";
        "tree(x)" = "trunk()..x";
        "stack(x)" = "trunk()..x";
        "overview()" = "@ | ancestors(remote_bookmarks(), 2) | trunk() | root()";
        "my_unmerged()" = "trunk()..mine()";
        "my_unmerged_remote()" = "trunk()..mine() & remote_bookmarks()";
        "not_pushed()" = "trunk()..remote_bookmarks()";
        "archived()" = "trunk()..(mine() & description(regex:'^archive($|:)'))";
        "unarchived(x)" = "trunk()..x ~ archived()";
        "diverge(x)" = "trunk()..x";
        # "working()" = "visible_heads() | ancestors(visible_heads(), 2)";
        "working()" = "trunk()..ancestors(visible_heads() & mutable(), 2)";
        "diff_xy(x, y)" = "trunk()..x & mutable() ~ trunk()..y & mutable()";
        "not_included(x, y)" = "trunk()..x..ancestors(y, 1)";
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
    ".config/fish/functions/jj-fork.fish" = {
      source = ../../conf/fish/funcs/jj-fork.fish;
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
