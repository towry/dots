# https://docs.github.com/en/copilot/reference/custom-agents-configuration
{
  config,
  pkgs,
  lib,
  ...
}:
let
  mcpServers = import ../../../modules/ai/mcp.nix { inherit pkgs lib; };
  copilotConfigDir = "${config.home.homeDirectory}/.copilot";
  mcpConfigFilePath = "${copilotConfigDir}/mcp-config.json";
  copilotMcpJson = builtins.toJSON ({
    mcpServers = mcpServers.clients.copilot;
  });
in
{
  home.activation = {
    setupCopilotConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${copilotConfigDir}
      cat ${pkgs.writeText "mcp-config.json" copilotMcpJson} > ${mcpConfigFilePath}

      echo "🧕🏻 Copilot config setup done"
    '';
  };
  home.file = {
    ".copilot/AGENTS.md".source = ../../../../conf/llm/docs/coding-rules.md;
    ".copilot/agents" = {
      source = ./agents;
      recursive = true;
    };
  };
}
