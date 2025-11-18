{
  pkgs,
  config,
  lib,
  ...
}:
let
  mcpServers = import ../../../modules/ai/mcp.nix { inherit pkgs lib config; };
  proxyConfig = import ../../../lib/proxy.nix { inherit lib pkgs; };
  forgeMcpJson = builtins.toJSON ({
    mcpServers = mcpServers.clients.forge;
  });
  forgeConfigDir = ./.; # Current directory containing all config files

  # Read and indent the coding rules for proper YAML formatting
  # Each line after the first needs to be indented with 2 spaces for YAML literal block
  codingRules =
    let
      rawRules = builtins.readFile ../../../../conf/llm/docs/coding-rules.md;
      lines = lib.splitString "\n" rawRules;
      indentedLines = lib.imap0 (i: line: if i == 0 then line else "  ${line}") lines;
    in
    lib.concatStringsSep "\n" indentedLines;

  # Process forge.yaml with variable substitution
  processedForgeYaml = pkgs.replaceVars (forgeConfigDir + "/forge.yaml") {
    RULE = codingRules;
  };

  # Wrapper to run forge with HTTP proxy configured
  forge-with-proxy = pkgs.writeShellScriptBin "forge-ai" ''
    export HTTP_PROXY="${proxyConfig.proxies.http}"
    export HTTPS_PROXY="${proxyConfig.proxies.https}"

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
      text = forgeMcpJson;
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

  home.packages = [
    forge-with-proxy
  ];
}
