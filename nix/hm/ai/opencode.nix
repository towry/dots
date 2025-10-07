{
  pkgs,
  config,
  lib,
  ...
}:

let
  ocode-with-proxy = pkgs.writeShellScriptBin "ocode" ''
    export HTTP_PROXY="http://127.0.0.1:1080"
    export HTTPS_PROXY="http://127.0.0.1:1080"

    # Execute the original opencode command with all arguments
    exec $HOME/.local/bin/opencode "$@"
  '';
in
{
  home.packages = with pkgs; [
    ocode-with-proxy
    # opencode
  ];
  # ++ (with pkgs.nix-ai-tools; [
  #   opencode
  # ]);

  home.activation = {
    setupOpencodeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${config.xdg.configHome}/opencode/

      cat ${../../../conf/llm/opencode/opencode.jsonc} > ${config.xdg.configHome}/opencode/opencode.jsonc
      cat ${../../../conf/llm/docs/coding-rules.md} > ${config.xdg.configHome}/opencode/AGENTS.md

      echo "Opencode config setup done"
    '';
  };

  xdg.configFile = {
    "opencode/agent" = {
      source = ../../../conf/llm/opencode/agent;
      recursive = true;
    };
    "opencode/plugin" = {
        source = ../../../conf/llm/opencode/plugin;
        recursive = true;
    };
    "opencode/command" = {
      source = ../../../conf/llm/opencode/command;
      recursive = true;
    };
  };
}
