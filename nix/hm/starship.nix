{ lib, ... }:
let
  enable_starship = true;
in
{
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
      };
      git_commit = {
        disabled = true;
        commit_hash_length = 6;
        style = "bold white";
      };
      git_status = {
        disabled = false;
      };
      git_state = {
        disabled = false;
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
        stgit = {
          command = "stg top";
          when = "stg top";
          require_repo = true;
          style = "bold purple";
          format = "[$symbol ($output )]($style)";
          symbol = "";
        };
      };
    };
  };
}
