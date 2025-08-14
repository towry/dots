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
  xdg = config.xdg;

in
{
  home.packages =
    with pkgs;
    [
      aichat
      # ollama
      github-mcp-server
      mcp-proxy
    ]
    ++ (with pkgs.nix-ai-tools; [
      opencode
    ]);

  programs.fish = {
    shellAliases = {
      goose-webdev = "goose run -s --recipe ${xdg.configHome}/goose/recipes/frontend-master.yaml";
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
                    set -l save_mode ""
                    set -l task_plan ""

                    # Process arguments
                    set -l i 1
                    while test $i -le (count $argv)
                      switch $argv[$i]
                        case -i
                          set interactive_mode "--interactive"
                        case --save
                          set save_mode "1"
                        case '*'
                          if test -z "$task_plan"
                            set task_plan $argv[$i]
                          end
                      end
                      set i (math $i + 1)
                    end

                    # Check if task plan was provided
                    if test -z "$task_plan"
                      echo "Usage: goose-review-plan [-i] [--save] <task_plan.md>"
                      echo "  -i      Enable interactive mode after review"
                      echo "  --save  Save the review report to task plan directory"
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
                    if test -n "$save_mode"
                      echo "Save mode enabled - review report will be saved"
                    end
                    echo "Using goose to analyze..."

                    # Build the command
                    set -l goose_cmd "goose run"
                    if test -n "$interactive_mode"
                      set goose_cmd $goose_cmd "--interactive"
                    end

                              # Read the system prompt from the config file
                    set -l prompt_file "${config.xdg.configHome}/goose/task-plan-review-prompt.md"
                    if not test -f $prompt_file
                      echo "Error: Task plan review prompt not found at $prompt_file"
                      return 1
                    end

                    # Read the prompt content
                    set -l system_prompt (cat $prompt_file)

                    # Build the text instruction
                    set -l text_instruction "Please review the task plan in: $task_plan \n
          Read the task plan file directly without checking its existence first."
                    if test -n "$save_mode"
                      # Generate the review report filename
                      set -l task_plan_dir (dirname $task_plan)
                      set -l task_plan_basename (basename $task_plan)
                      set -l task_plan_name (string replace -r "\\.[^.]*\$" "" $task_plan_basename)
                      set -l review_report_path "$task_plan_dir/$task_plan_name-review-report.md"
                      set text_instruction "$text_instruction

          After completing the review, save the review report to: $review_report_path"
                    end

                    # Build the full command arguments
                    set -l goose_args
                    if test -n "$interactive_mode"
                      set goose_args $goose_args --interactive
                    end
                    set goose_args $goose_args --max-tool-repetitions 50
                    set goose_args $goose_args --system "$system_prompt"
                    set goose_args $goose_args --text "$text_instruction"

                    # Execute the command
                    goose run $goose_args
        '';
      };
    };
  };

  home.activation = {
    setupGooseConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      cat ${config.xdg.configHome}/goose/config-source.yaml > ${config.xdg.configHome}/goose/config.yaml
      chmod u+w ${config.xdg.configHome}/goose/config.yaml
      echo "goose config setup done"
      # copy the goose recipes to the goose recipes directory
      mkdir -p ${config.xdg.configHome}/goose/recipes
      cp -rf ${config.xdg.configHome}/goose/goose-recipes_/* ${config.xdg.configHome}/goose/recipes/
      echo "goose recipes copied to ${config.xdg.configHome}/goose/recipes"
    '';

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
      echo "Forge config updated"
    '';
  };

  xdg.configFile = {
    "goose/config-source.yaml" = {
      source = pkgs.replaceVars ../../conf/llm/goose/config.yaml {
        GITHUB_PERSONAL_ACCESS_TOKEN = pkgs.nix-priv.keys.github.accessToken;
        BRAVE_API_KEY = pkgs.nix-priv.keys.braveSearch.apiKey;
        # ANYTYPE_API_KEY = pkgs.nix-priv.keys.anytype.apiKey;
        # STACKOVERFLOW_API_KEY = pkgs.nix-priv.keys.stackoverflow.apiKey;
        MASTERGO_TOKEN = pkgs.nix-priv.keys.mastergo.token;
      };
    };
    "goose/.goosehints" = {
      source = ../../conf/llm/docs/coding-rules.md;
    };
    "goose/task-plan-review-prompt.md" = {
      source = ../../conf/llm/docs/prompts/task-plan-review.md;
    };
    "goose/goose-recipes_" = {
      source = ../../conf/llm/goose-recipes;
      recursive = true;
    };
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
    "goose-recipes" = {
      enable = true;
      target = "${config.home.homeDirectory}/workspace/goose-recipes_";
      source = ../../conf/llm/goose-recipes;
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
    "goose-run-plan" = {
      enable = true;
      source = ../../conf/bash/scripts/goose-run-plan.sh;
      target = ".local/bin/goose-run-plan";
      executable = true;
    };
    "goose-role" = {
      source = ../../conf/bash/scripts/goose-role;
      target = ".local/bin/goose-role";
      executable = true;
    };
  };
}
