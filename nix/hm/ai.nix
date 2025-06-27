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

  # Read and escape the system prompt for shell usage
  taskPlanReviewPrompt = lib.escapeShellArg (builtins.readFile ../../conf/llm/docs/prompts/task-plan-review.md);

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
      goose-review-plan = {
        description = "Review task plan";

        body = ''
          # Parse arguments
          set -l interactive_mode ""
          set -l task_plan ""

          # Process arguments
          set -l i 1
          while test $i -le (count $argv)
            switch $argv[$i]
              case -i
                set interactive_mode "--interactive"
              case '*'
                if test -z "$task_plan"
                  set task_plan $argv[$i]
                end
            end
            set i (math $i + 1)
          end

          # Check if task plan was provided
          if test -z "$task_plan"
            echo "Usage: goose-review-plan [-i] <task_plan.md>"
            echo "  -i    Enable interactive mode after review"
            return 1
          end

          if not test -f $task_plan
            echo "Error: Task plan file '$task_plan' not found"
            return 1
          end

          echo "Reviewing task plan: $task_plan"
          if test -n "$interactive_mode"
            echo "Interactive mode enabled"
          end
          echo "Using goose to analyze..."

          goose run $interactive_mode --max-tool-repetitions 50 --system ${taskPlanReviewPrompt} --text "Please review the task plan: $task_plan"
        '';
      };
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
