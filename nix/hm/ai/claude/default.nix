{
  pkgs,
  config,
  lib,
  ...
}:
let
  claudeConfigDir = ./.; # Current directory containing all config files
  # claudeTargetConfigDir = "${config.home.homeDirectory}/.claude"; # Target directory in home
  # claudeUserScriptsDir = "${claudeTargetConfigDir}/scripts_"; # Directory for user scripts
  kiroSystemPromptHbs = builtins.readFile ../roles-md/kiro-system-prmpt.md;
  lifeguardRole = builtins.readFile ../roles-md/lifeguard-role.md;

  # Process settings.json with variable substitution
  processedSettings = pkgs.replaceVars (claudeConfigDir + "/settings.json") {
    # Add any variable substitutions if needed
  };

  # Process CLAUDE.md by reading coding-rules.md and substituting @CONTENT@
  processedClaudeMd = pkgs.replaceVars (claudeConfigDir + "/assets/CLAUDE.md") {
    CONTENT = builtins.readFile ../../../../conf/llm/docs/coding-rules.md;
  };

  claudeScriptPrelude = ''
    set -euo pipefail

    export HTTP_PROXY="http://127.0.0.1:7898"
    export HTTPS_PROXY="http://127.0.0.1:7898"
    export NO_PROXY="localhost,127.0.0.1,0.0.0.0"
    export DISABLE_AUTOUPDATER=1
    export DISABLE_BUG_COMMAND=1
    export DISABLE_TELEMETRY=1
    export MAX_MCP_OUTPUT_TOKENS=900000
    # Suppress the init-kiro.sh info message
    export KIRO_QUIET=1
  '';

  mkClaudeWrapper =
    name: body:
    pkgs.writeShellScriptBin name ''
      ${claudeScriptPrelude}

      ${body}
    '';

  kiroPromptLiteral = lib.escapeShellArg kiroSystemPromptHbs;
  lifeguardPromptLiteral = lib.escapeShellArg lifeguardRole;

  claudeScripts = {
    claude-lifeguard = mkClaudeWrapper "claude-lifeguard" ''
      exec claude --system-prompt ${lifeguardPromptLiteral} --strict-mcp-config "$@"
    '';
    claude-ai = mkClaudeWrapper "claude-ai" ''
      # Check if --pr flag is present
      use_pr_mode=false
      for arg in "$@"; do
        if [[ "$arg" == "--pr" ]]; then
          use_pr_mode=true
          break
        fi
      done

      if [[ "$use_pr_mode" == "true" ]]; then
        # Remove --pr from arguments
        args=()
        for arg in "$@"; do
          if [[ "$arg" != "--pr" ]]; then
            args+=("$arg")
          fi
        done

        # Get PR directory from agpod
        pr_dir="$(agpod kiro pr --output abs)"
        exit_code=$?

        if [[ $exit_code -ne 0 ]]; then
          echo "Error: Failed to get PR directory from agpod" >&2
          exit $exit_code
        fi

        if [[ -z "$pr_dir" ]]; then
          echo "Error: No PR directory selected" >&2
          exit 1
        fi

        # Build kiro system prompt
        kiro_prompt_template=${kiroPromptLiteral}

        # Create JSON context with pr_dir
        context_json="$(printf '{"pr_dir":"%s"}' "$pr_dir")"

        # Render template with minijinja
        template_file="$(mktemp)"
        printf '%s' "$kiro_prompt_template" > "$template_file"

        system_prompt="$(printf '%s' "$context_json" | minijinja-cli -f json "$template_file" - 2>&1)"
        minijinja_exit=$?
        rm -f "$template_file"

        if [[ $minijinja_exit -ne 0 || -z "$system_prompt" ]]; then
          echo "Error: Failed to render kiro prompt template" >&2
          exit 1
        fi

        # Execute claude with kiro system prompt
        exec claude --system-prompt "$system_prompt" --mcp-config "$HOME/.claude/.mcp.json" "''${args[@]}"
      else
        # Normal mode: just run claude with all arguments
        exec claude --mcp-config "$HOME/.claude/.mcp.json" "$@"
      fi
    '';
  };
in
{
  # Generated files for activation script to copy
  home.file = {
    ".claude/generated/settings.json" = {
      source = processedSettings;
    };
    ".claude/generated/.mcp.json" = {
      source = claudeConfigDir + "/mcp.json";
    };
    ".claude/CLAUDE.md" = {
      source = processedClaudeMd;
    };

    # Direct symlinks for agents (read-only, won't be edited)
    ".claude/agents" = {
      source = claudeConfigDir + "/agents";
      recursive = true;
    };
    ".claude/commands" = {
      source = claudeConfigDir + "/commands";
      recursive = true;
    };
  };

  # Activation script to copy settings.json and .mcp.json
  # These files need to be editable by the claude program
  home.activation = {
    setupClaudeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      CLAUDE_DIR="${config.home.homeDirectory}/.claude"
      GENERATED_DIR="$CLAUDE_DIR/generated"

      # Create directory if it doesn't exist
      mkdir -p "$CLAUDE_DIR"

      # Always copy settings.json (override existing)
      echo "Copying settings.json to ~/.claude/"
      cp -f "$GENERATED_DIR/settings.json" "$CLAUDE_DIR/settings.json"
      chmod u+w "$CLAUDE_DIR/settings.json"

      # Always copy .mcp.json (override existing)
      echo "Copying .mcp.json to ~/.claude/"
      cp -f "$GENERATED_DIR/.mcp.json" "$CLAUDE_DIR/.mcp.json"
      chmod u+w "$CLAUDE_DIR/.mcp.json"

      echo "Claude config setup done"
    '';
  };

  home.packages = (builtins.attrValues claudeScripts) ++ [
    pkgs.minijinja
  ];
}
