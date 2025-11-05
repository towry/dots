{
  pkgs,
  config,
  lib,
  ...
}:
let
  windsurfConfigDir = ./.;
  processedWindsurfMd = pkgs.replaceVars (windsurfConfigDir + "/rules.md") {
    CONTENT = builtins.readFile ../../../../conf/llm/docs/coding-rules.md;
  };

  windsurfMcpConfig = pkgs.replaceVars (windsurfConfigDir + "/mcp_config.json") {
    BRIGHTDATA_API_KEY = pkgs.nix-priv.keys.brightdata.apiKey;
    GITHUB_PAT = pkgs.nix-priv.keys.github.accessToken;
  };
in
{
  home.file = {
    ".codeium/generated/memories/global_rules.md" = {
      source = processedWindsurfMd;
    };
    ".codeium/generated/workflows" = {
      source = windsurfConfigDir + "/workflows";
      recursive = true;
    };
    ".codeium/generated/mcp_config.json" = {
      source = windsurfMcpConfig;
    };
  };

  programs.fish = {
    loginShellInit = ''
      fish_add_path ${config.home.homeDirectory}/.codeium/windsurf/bin
    '';
  };

  home.activation = {
    setupWindsurf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      GEN_DIR="${config.home.homeDirectory}/.codeium/generated"
      WS_DIR="${config.home.homeDirectory}/.codeium/windsurf"
      WS_NEXT_DIR="${config.home.homeDirectory}/.codeium/windsurf-next"

      mkdir -p "$WS_DIR/memories" "$WS_DIR/global_workflows"
      mkdir -p "$WS_NEXT_DIR/memories" "$WS_NEXT_DIR/global_workflows"

      cp -rf $GEN_DIR/memories/* "$WS_DIR/memories/"
      cp -rf $GEN_DIR/workflows/* "$WS_DIR/global_workflows/"
      cp -rf $GEN_DIR/memories/* "$WS_NEXT_DIR/memories/"
      cp -rf $GEN_DIR/workflows/* "$WS_NEXT_DIR/global_workflows/"

      cat $GEN_DIR/mcp_config.json > $WS_DIR/mcp_config.json
      cat "$GEN_DIR/mcp_config.json" > "$WS_NEXT_DIR/mcp_config.json"

      echo "🧕🏻 Windsurf config setup done"
    '';
  };
}
