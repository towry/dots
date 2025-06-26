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
  ];

  programs.fish = {
    shellAliases = {
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
    setupGooseConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      cat ${config.xdg.configHome}/goose/config-source.yaml > ${config.xdg.configHome}/goose/config.yaml
      chmod u+w ${config.xdg.configHome}/goose/config.yaml
      echo "goose config setup done"
    '';
  };

  xdg.configFile = {
    "goose/config-source.yaml" = {
      source = pkgs.replaceVars ../../conf/llm/goose/config.yaml {
        GITHUB_PERSONAL_ACCESS_TOKEN = pkgs.nix-priv.keys.github.accessToken;
        BRAVE_API_KEY = pkgs.nix-priv.keys.braveSearch.apiKey;
        ANYTYPE_API_KEY = pkgs.nix-priv.keys.anytype.apiKey;
      };
    };
    "goose/.goosehints" = {
      source = ../../conf/llm/docs/coding-rules.md;
    };
  };

  home.file = {
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
    "goose-run-plan" = {
      enable = true;
      source = ../../conf/bash/scripts/goose-run-plan.sh;
      target = ".local/bin/goose-run-plan";
      executable = true;
    };
  };
}
