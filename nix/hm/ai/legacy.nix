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

  programs.fish = {
    shellAliases = { };
    functions = { };
  };

  home.activation = {
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

  # xdg.configFile configurations moved to specific modules

  home.file = {
    "kilocode-rule" = {
      target = "${config.home.homeDirectory}/.kilocode/rules/agents.md";
      source = ../../../conf/llm/docs/coding-rules.md;
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
