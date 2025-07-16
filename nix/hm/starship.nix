{
  lib,
  pkgs,
  config,
  ...
}:
let
  enable_starship = true;
in
{

  home.packages = [
    pkgs.starship-jj
  ];

  xdg.configFile = {
    "starship-jj/starship-jj.toml" = {
      text = ''
        [bookmarks]
        search_depth = 10

        [[module]]
        type = "Bookmarks"
        separator = " "
        color = "Magenta"
        max_bookmarks = 1
        max_length = 50
        surround_with_quotes = false
      '';
    };
  };

  programs.starship = {
    enable = enable_starship;
    enableTransience = false;
    settings = {
      format = lib.concatStrings [ "$all" ];
      right_format = lib.concatStrings [ "$time" ];
      command_timeout = 300;
      scan_timeout = 10;
      follow_symlinks = false;
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green) ";
        error_symbol = "[✗](bold red) ";
      };
      directory = {
        truncate_to_repo = false;
        truncation_length = 3;
        style = "bold cyan";
        before_repo_root_style = "fg:blue";
        repo_root_style = "bold cyan";
        format = "[$path]($style)[$lock_symbol]($lock_style)";
      };
      cmd_duration = {
        disabled = true;
        # 10 sec
        min_time = 10000;
        format = " took [$duration]($style)";
      };
      git_branch = {
        format = "\\[[$symbol$branch]($style)\\] ";
        style = "bold yellow";
        symbol = "";
        disabled = true;
      };
      git_commit = {
        disabled = true;
        commit_hash_length = 6;
        style = "bold white";
      };
      git_status = {
        disabled = true;
      };
      git_state = {
        disabled = true;
        format = "[\($state( $progress_current of $progress_total)\)]($style) ";
      };
      memory_usage = {
        format = "$symbol[\${ram}( | \${swap})]($style) ";
        threshold = 70;
        style = "bold dimmed white";
        disabled = true;
      };
      package = {
        disabled = true;
      };
      python = {
        disabled = false;
        style = "bold green";
      };
      rust = {
        disabled = true;
        format = "[$symbol$version]($style) ";
        style = "bold green";
      };
      time = {
        time_format = "%T";
        format = "$time($style) ";
        style = "bright-white";
        disabled = false;
      };
      username = {
        style_user = "bold dimmed blue";
        show_always = false;
      };
      nodejs = {
        disabled = false;
        format = "via [🤖 $version](bold green) ";
      };
      direnv = {
        disabled = false;
        loaded_msg = "✅";
        allowed_msg = "👌";
        unloaded_msg = "🔽";
        denied_msg = "⛔";
        not_allowed_msg = "😤";
      };
      nix_shell = {
        disabled = false;
        impure_msg = "[impure](bold red)";
        unknown_msg = "[unknown](bold yellow)";
        pure_msg = "[pure](bold green)";
      };
      battery = {
        disabled = true;
      };
      lua = {
        disabled = true;
      };
      status = {
        disabled = true;
      };
      custom = {
        jj = {
          command = "prompt";
          format = "$output";
          ignore_timeout = true;
          shell = [
            "starship-jj"
            "--ignore-working-copy"
            "starship"
          ];
          use_stdin = false;
          when = true;

        };
        gittown = {
          disabled = !config.vars.git-town.enable;
          description = "Git Town";
          symbol = "🛖";
          require_repo = true;
          command = "prompt";
          format = "[$symbol ($output)]($style)";
          use_stdin = false;
          when = true;
          shell = [
            "git-town"
            "status"
            "--pending"
          ];
        };
      };
    };
  };
}
