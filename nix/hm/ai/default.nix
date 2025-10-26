{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./opencode.nix
    ./legacy.nix
    # ./droid
    ./claude
    ./codex
    ./windsurf
    # ./cline
  ];
  home.activation = {
    setupGlobalAgents = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${config.home.homeDirectory}/.config"
      cat ${../../../conf/llm/docs/coding-rules.md} > "${config.home.homeDirectory}/.config/AGENTS.md"
      echo "AGENTS.md updated"
    '';
  };
  home.packages = [
    pkgs.agpod
  ];
}
