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
  home.packages =
    with pkgs;
    [
      aichat
      # ollama
      github-mcp-server
      # mcp-proxy
    ];
    # ++ (with pkgs.nix-ai-tools; [
    #   opencode
    # ]);

  programs.fish = {
    shellAliases = {
      gen-copilot-spec = "uvx --from git+https://github.com/github/spec-kit.git specify init";
    };
    functions = {
      gen-task-prompt = ''
        mkdir -p /tmp/llm-task-prompt
        set timestamp (date +%Y-%m-%d-%H-%M-%S)
        set tmpfile "/tmp/llm-task-prompt/$timestamp.md"
        $EDITOR $tmpfile
        if test -s $tmpfile
          mkdir -p llm/task-plan-prompts
          set output_file "llm/task-plan-prompts/task_plan_$timestamp.md"
          cat $tmpfile | aichat --role gen-prompt > $output_file
          echo "Task plan generated: $output_file"
          echo "Original prompt saved: $tmpfile"
        else
          echo "No content provided, aborting."
          rm -f $tmpfile
        end
      '';
    };
  };

  home.activation = {
    setupOpencodeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${config.xdg.configHome}/opencode/
      cat ${../../conf/llm/opencode/opencode.jsonc} > ${config.xdg.configHome}/opencode/opencode.jsonc
      cat ${../../conf/llm/docs/coding-rules.md} > ${config.xdg.configHome}/opencode/instructions.md
      echo "Opencode config setup done"
    '';

    updateRooCodeGlobalRule = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${config.home.homeDirectory}/.roo/rules/
      echo "Updating roo global rules..."
      cat ${../../conf/llm/docs/coding-rules.md} > ${config.home.homeDirectory}/.roo/rules/global_rules.md
      echo "Roo global rules updated"
    '';

    updateForgeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${config.home.homeDirectory}/forge/
      echo "Updating forge config..."
      cat ${../../conf/llm/forge/forge.yaml} > ${config.home.homeDirectory}/forge.yaml
      cat ${../../conf/llm/forge/mcp.json} > ${config.home.homeDirectory}/forge/.mcp.json
      echo "Forge config updated"
    '';

    updateWindsurfGlobalRule = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${config.home.homeDirectory}/.codeium/windsurf/memories/
      # write the conf/llm/coding-rules.md content to the global_rules.md file in above dir.
      echo "Updating windsurf global rules..."
      cat ${../../conf/llm/docs/coding-rules.md} > ${config.home.homeDirectory}/.codeium/windsurf/memories/global_rules.md
      echo "Windsurf global rules updated"

      cp -rf ${../../conf/llm/windsurf/workflows}/*.md ${config.home.homeDirectory}/.codeium/windsurf/windsurf/workflows/
      echo "Windsurf workflows updated"

      echo "Updating AGENTS.md in xdg config dir..."
      cat ${../../conf/llm/docs/coding-rules.md} > ${config.home.homeDirectory}/.config/AGENTS.md
    '';
  };

  xdg.configFile = {
    "opencode/agent" = {
      source = ../../conf/llm/opencode/agent;
      recursive = true;
    };
  };

  home.file = {
    "kilocode-rule" = {
      enable = true;
      target = "${config.home.homeDirectory}/.kilocode/rules/coding_standards.md";
      source = ../../conf/llm/docs/coding-rules.md;
    };
    "forge-agents" = {
      enable = true;
      target = "${config.home.homeDirectory}/forge/agents";
      source = ../../conf/llm/forge/agents;
      recursive = true;
    };
    "${aichatConfigDir}/roles" = {
      # link to ../../conf/llm/aichat/roles dir
      source = ../../conf/llm/aichat/roles;
      recursive = true;
    };
    "${aichatConfigDir}/config.yaml" = {
      source = pkgs.replaceVars ../../conf/llm/aichat/config.yaml {
        DEEPSEEK_API_KEY = pkgs.nix-priv.keys.deepseek.apiKey;
        OPENROUTER_API_KEY = pkgs.nix-priv.keys.openrouter.apiKey;
      };
    };
  };
}
