{
  pkgs,
  config,
  lib,
  ...
}:
let
  forgeConfigDir = ./.; # Current directory containing all config files

  # Process forge.yaml with variable substitution
  processedForgeYaml = pkgs.replaceVars (forgeConfigDir + "/forge.yaml") {
    # Add any variable substitutions if needed in the future
  };

  # Process mcp.json with variable substitution
  processedMcp = pkgs.replaceVars (forgeConfigDir + "/mcp.json") {
    GITHUB_PERSONAL_ACCESS_TOKEN = pkgs.nix-priv.keys.github.accessToken;
    BRIGHTDATA_API_KEY = pkgs.nix-priv.keys.brightdata.apiKey;
  };

  # Wrapper to run forge with HTTP proxy configured
  forge-with-proxy = pkgs.writeShellScriptBin "forge-ai" ''
    export HTTP_PROXY="http://127.0.0.1:7898"
    export HTTPS_PROXY="http://127.0.0.1:7898"

    # Execute the original forge command with all arguments
    exec forge "$@"
  '';
in
{
  # Direct symlinks for agents (read-only, won't be edited)
  home.file = {
    "forge/agents" = {
      source = forgeConfigDir + "/agents";
      recursive = true;
    };

    # Generated files for activation script to copy
    "forge/.generated/forge.yaml" = {
      source = processedForgeYaml;
    };
    "forge/.generated/mcp.json" = {
      source = processedMcp;
    };
  };

  # Activation script to copy forge.yaml and mcp.json
  # These files need to be editable by the forge program
  home.activation = {
    setupForgeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      HOME_DIR="${config.home.homeDirectory}"
      GENERATED_DIR="$HOME_DIR/forge/.generated"

      # Always copy forge.yaml to home directory root (override existing)
      echo "Copying forge.yaml to ~/"
      cp -f "$GENERATED_DIR/forge.yaml" "$HOME_DIR/forge.yaml"
      chmod u+w "$HOME_DIR/forge.yaml"

      # Always copy mcp.json to ~/forge/.mcp.json (override existing)
      echo "Copying .mcp.json to ~/forge/"
      mkdir -p "$HOME_DIR/forge"
      cp -f "$GENERATED_DIR/mcp.json" "$HOME_DIR/forge/.mcp.json"
      chmod u+w "$HOME_DIR/forge/.mcp.json"

      echo "Forge config setup done"
    '';
  };

  home.packages = with pkgs; [
    forge-with-proxy
  ];
}
