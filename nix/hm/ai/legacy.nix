{
  pkgs,
  config,
  lib,
  ...
}:

let
  aichatConfigDir =
    if pkgs.stdenv.isDarwin then
      "${config.home.homeDirectory}/Library/Application Support/aichat"
    else
      "${config.home.homeDirectory}/.config/aichat";

in
{
  home.packages = with pkgs; [
    aichat
    # ollama
    github-mcp-server
    # mcp-proxy
  ];
  # ++ (with pkgs.nix-ai-tools; [
  #   opencode
  # ]);

  programs.fish = {
    shellAliases = { };
    functions = { };
  };

  home.activation = {
    setupOpencodeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${config.xdg.configHome}/opencode/
      cat ${../../../conf/llm/opencode/opencode.jsonc} > ${config.xdg.configHome}/opencode/opencode.jsonc
      cat ${../../../conf/llm/docs/coding-rules.md} > ${config.xdg.configHome}/opencode/instructions.md
      echo "Opencode config setup done"
    '';

    updateForgeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${config.home.homeDirectory}/forge/
      echo "Updating forge config..."
      cat ${../../../conf/llm/forge/forge.yaml} > ${config.home.homeDirectory}/forge.yaml
      cat ${../../../conf/llm/forge/mcp.json} > ${config.home.homeDirectory}/forge/.mcp.json
      echo "Forge config updated"
    '';

    updateWindsurfGlobalRule = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${config.home.homeDirectory}/.codeium/windsurf/memories/
      # write the conf/llm/coding-rules.md content to the global_rules.md file in above dir.
      echo "Updating windsurf global rules..."
      cat ${../../../conf/llm/docs/coding-rules.md} > ${config.home.homeDirectory}/.codeium/windsurf/memories/global_rules.md
      echo "Windsurf global rules updated"

      mkdir -p ${config.home.homeDirectory}/.codeium/windsurf/workflows/
      cp -rf ${../../../conf/llm/windsurf/workflows}/*.md ${config.home.homeDirectory}/.codeium/windsurf/workflows/
      echo "Windsurf workflows updated"

      echo "Updating AGENTS.md in xdg config dir..."
      cat ${../../../conf/llm/docs/coding-rules.md} > ${config.home.homeDirectory}/.config/AGENTS.md
    '';
  };

  xdg.configFile = {
    "opencode/agent" = {
      source = ../../../conf/llm/opencode/agent;
      recursive = true;
    };
  };

  home.file = {
    "forge-agents" = {
      enable = true;
      target = "${config.home.homeDirectory}/forge/agents";
      source = ../../../conf/llm/forge/agents;
      recursive = true;
    };
    "${aichatConfigDir}/roles" = {
      # link to ../../../conf/llm/aichat/roles dir
      source = ../../../conf/llm/aichat/roles;
      recursive = true;
    };
    "${aichatConfigDir}/config.yaml" = {
      source = pkgs.replaceVars ../../../conf/llm/aichat/config.yaml {
        DEEPSEEK_API_KEY = pkgs.nix-priv.keys.deepseek.apiKey;
        OPENROUTER_API_KEY = pkgs.nix-priv.keys.openrouter.apiKey;
        ZHIPU_API_KEY = pkgs.nix-priv.keys.zai.apiKey;
      };
    };
  };
}
