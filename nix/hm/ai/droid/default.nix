{
  pkgs,
  config,
  lib,
  ...
}:
let
  droidConfigDir = ./.; # Current directory containing all config files

  # Process settings.json with variable substitution
  processedSettings = pkgs.replaceVars (droidConfigDir + "/settings.json") {
    # OPENROUTER_API_KEY = pkgs.nix-priv.keys.openrouter.apiKey;
  };

  processedConfig = pkgs.replaceVars (droidConfigDir + "/config.json") {
    OPENROUTER_API_KEY = pkgs.nix-priv.keys.openrouter.apiKey;
    ZHIPU_CODING_PLAN = pkgs.nix-priv.keys.zai.apiKey;
    LITELLM_API_KEY = pkgs.nix-priv.keys.litellm.apiKey;
  };

  # Process AGENTS.md by reading coding-rules.md and substituting @CONTENT@
  processedAgentsMd = pkgs.replaceVars (droidConfigDir + "/AGENTS.md") {
    CONTENT = builtins.readFile ../../../../conf/llm/docs/coding-rules.md;
  };

  # Process mcp.json with variable substitution
  processedMcp = pkgs.replaceVars (droidConfigDir + "/mcp.json") {
    GITHUB_PERSONAL_ACCESS_TOKEN = pkgs.nix-priv.keys.github.accessToken;
    TAVILY_API_KEY = pkgs.nix-priv.keys.tavily.mcpUrl;
    KG_SSE = pkgs.nix-priv.keys.kg.sse;
    KG_API_KEY = pkgs.nix-priv.keys.kg.apiKey;
    MASTERGO_API_KEY = pkgs.nix-priv.keys.mastergo.token;
  };

  # Wrapper to run droid with HTTP proxy configured
  factory-with-proxy = pkgs.writeShellScriptBin "factory" ''
    export HTTP_PROXY="http://127.0.0.1:7898"
    export HTTPS_PROXY="http://127.0.0.1:7898"

    # Execute the original droid command with all arguments
    exec droid "$@"
  '';
in
{
  # Direct symlinks for droids and commands (read-only, won't be edited)
  home.file = {
    ".factory/droids" = {
      source = droidConfigDir + "/droids";
      recursive = true;
    };

    ".factory/commands" = {
      source = droidConfigDir + "/commands";
      recursive = true;
    };

    # Generated files for activation script to copy
    ".factory/generated/settings.json" = {
      source = processedSettings;
    };
    ".factory/generated/config.json" = {
      source = processedConfig;
    };
    ".factory/generated/mcp.json" = {
      source = processedMcp;
    };
    ".factory/AGENTS.md" = {
      source = processedAgentsMd;
    };
  };

  # Activation script to copy only settings.json and mcp.json
  # These files need to be editable by the droid program
  home.activation = {
    setupDroidConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      FACTORY_DIR="${config.home.homeDirectory}/.factory"
      GENERATED_DIR="$FACTORY_DIR/generated"

      # Always copy settings.json (override existing)
      echo "Copying settings.json to ~/.factory/"
      cp -f "$GENERATED_DIR/settings.json" "$FACTORY_DIR/settings.json"
      chmod u+w "$FACTORY_DIR/settings.json"

      cp -f "$GENERATED_DIR/config.json" "$FACTORY_DIR/config.json"
      chmod u+w "$FACTORY_DIR/config.json"

      # Always copy mcp.json (override existing)
      echo "Copying mcp.json to ~/.factory/"
      cp -f "$GENERATED_DIR/mcp.json" "$FACTORY_DIR/mcp.json"
      chmod u+w "$FACTORY_DIR/mcp.json"

      echo "Droid config setup done"
    '';
  };

  home.packages = [
    factory-with-proxy
  ];
}
