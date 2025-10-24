{
  pkgs,
  config,
  lib,
  ...
}:

let
  kiroSystemPromptHbs = ''
    # Welcome to Kiro, the AI coding assistant.
    - Our **kiro spec dir**: {{pr_dir}}

    @sage please summarize the kiro status:

    - Read @{{pr_dir}}/claude.md, decide which other spec files to read.
    - To maintain requirements: @{{pr_dir}}/requirements.md
    - To maintain design/plan: @{{pr_dir}}/design.md
    - To maintain tasks: @{{pr_dir}}/tasks.md
  '';
  kiroPromptLiteral = lib.escapeShellArg kiroSystemPromptHbs;

  ocode-with-proxy = pkgs.writeShellScriptBin "ocode" ''
    export HTTP_PROXY="http://127.0.0.1:1080"
    export HTTPS_PROXY="http://127.0.0.1:1080"

    # Check if --pr flag is present
    use_pr_mode=false
    for arg in "$@"; do
      if [[ "$arg" == "--pr" ]]; then
        use_pr_mode=true
        break
      fi
    done

    if [[ "$use_pr_mode" == "true" ]]; then
      # Remove --pr from arguments
      args=()
      for arg in "$@"; do
        if [[ "$arg" != "--pr" ]]; then
          args+=("$arg")
        fi
      done

      # Get PR directory from agpod
      pr_dir="$(agpod kiro pr --output abs)"
      exit_code=$?

      if [[ $exit_code -ne 0 ]]; then
        echo "Error: Failed to get PR directory from agpod" >&2
        exit $exit_code
      fi

      if [[ -z "$pr_dir" ]]; then
        echo "Error: No PR directory selected" >&2
        exit 1
      fi

      # Build kiro system prompt
      kiro_prompt_template=${kiroPromptLiteral}

      # Create JSON context with pr_dir
      context_json="$(printf '{"pr_dir":"%s"}' "$pr_dir")"

      # Render template with minijinja
      template_file="$(mktemp)"
      printf '%s' "$kiro_prompt_template" > "$template_file"

      system_prompt="$(printf '%s' "$context_json" | minijinja-cli -f json "$template_file" - 2>&1)"
      minijinja_exit=$?
      rm -f "$template_file"

      if [[ $minijinja_exit -ne 0 || -z "$system_prompt" ]]; then
        echo "Error: Failed to render kiro prompt template" >&2
        exit 1
      fi

      # Execute opencode with kiro system prompt and plan agent
      exec $HOME/.local/bin/opencode --prompt "$system_prompt" --agent kiro "''${args[@]}"
    else
      # Normal mode: just run opencode with all arguments
      exec $HOME/.local/bin/opencode "$@"
    fi
  '';
in
{
  home.packages = [
    ocode-with-proxy
    pkgs.terminal-notifier
    pkgs.minijinja
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
    "opencode/roles" = {
      source = ../../../conf/llm/opencode/roles;
      recursive = true;
    };
  };
}
