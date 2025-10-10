{
  pkgs,
  config,
  lib,
  ...
}:
let
  claudeConfigDir = ./.; # Current directory containing all config files

  # Process settings.json with variable substitution
  processedSettings = pkgs.replaceVars (claudeConfigDir + "/settings.json") {
    # Add any variable substitutions if needed
  };

  # Process CLAUDE.md by reading coding-rules.md and substituting @CONTENT@
  processedClaudeMd = pkgs.replaceVars (claudeConfigDir + "/CLAUDE.md") {
    CONTENT = builtins.readFile ../../../../conf/llm/docs/coding-rules.md;
  };

  # Wrapper to run claude with HTTP proxy and environment variables
  claude-with-proxy = pkgs.writeShellScriptBin "claude-ai" ''
    export HTTP_PROXY="http://127.0.0.1:1080"
    export HTTPS_PROXY="http://127.0.0.1:1080"

    # Execute the original claude command with MCP config and all arguments
    exec claude --mcp-config "$HOME/.claude/.mcp.json" "$@"
  '';
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

  home.packages = with pkgs; [
    claude-with-proxy
  ];
}
