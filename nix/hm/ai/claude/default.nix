{
  pkgs,
  config,
  lib,
  ...
}:
let
  mcpServers = import ../../../modules/ai/mcp.nix { inherit pkgs lib config; };
  proxyConfig = import ../../../lib/proxy.nix { inherit lib pkgs; };
  claudeMcpJson = builtins.toJSON ({
    mcpServers = mcpServers.clients.claude;
  });
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

    export HTTP_PROXY="${proxyConfig.proxies.http}"
    export HTTPS_PROXY="${proxyConfig.proxies.https}"
    export NO_PROXY="${proxyConfig.noProxyString}"
    export DISABLE_AUTOUPDATER=1
    export DISABLE_BUG_COMMAND=1
    export DISABLE_TELEMETRY=1
    export MAX_MCP_OUTPUT_TOKENS=25000
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
    claude-ai = mkClaudeWrapper "cla" ''
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
        exec claude --system-prompt "$system_prompt" --mcp-config "$HOME/.mcp.json" "''${args[@]}"
      else
        # Normal mode: just run claude with all arguments
        exec claude --mcp-config "$HOME/.mcp.json" "$@"
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
    ".claude/hooks" = {
      source = claudeConfigDir + "/hooks";
      recursive = true;
    };
    ".claude/skills" = {
      source = ../../../../conf/claude-local-marketplace/skills;
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
      # claude look up for .mcp.json and use it
      echo '${claudeMcpJson}' > "$HOME/.mcp.json"

      echo "🧕🏻 Claude config setup done"
    '';
  };

  home.packages = (builtins.attrValues claudeScripts) ++ [
    pkgs.minijinja
  ];
  home.sessionVariables = {
    CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR = 1;
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1;
    DISABLE_NON_ESSENTIAL_MODEL_CALLS = 1;
    BASH_MAX_OUTPUT_LENGTH = 2048;
    CLAUDE_CODE_MAX_OUTPUT_TOKENS = 16000;
    DISABLE_COST_WARNINGS = 1;
    MAX_MCP_OUTPUT_TOKENS = 25000;
    DISABLE_TELEMETRY = 1;
    USE_BUILTIN_RIPGREP = 0;
  };
}
