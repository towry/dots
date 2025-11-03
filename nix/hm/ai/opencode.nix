{
  pkgs,
  config,
  lib,
  ...
}:

let
  mcpServers = import ../../modules/ai/mcp.nix { inherit pkgs lib; };
  proxyConfig = import ../../lib/proxy.nix { inherit lib; };
  opencodeConfigModule = import ../../modules/ai/opencode-config.nix { inherit lib; };
  opencodeConfig = opencodeConfigModule.config // {
    mcp = mcpServers.clients.opencode;
  };
  opencodeConfigJson = builtins.toJSON opencodeConfig;
  kiroSystemPromptHbs = ''
    Our **kiro spec dir**: {{pr_dir}}
    **ask** @sage subagent please summarize the kiro status:

    - Read @{{pr_dir}}/claude.md, decide which other spec files to read.
    - To maintain requirements: @{{pr_dir}}/requirements.md
    - To maintain design/plan: @{{pr_dir}}/design.md
    - To maintain tasks: @{{pr_dir}}/tasks.md
  '';
  kiroPromptLiteral = lib.escapeShellArg kiroSystemPromptHbs;

  ocode-with-proxy = pkgs.writeShellScriptBin "ocode" ''
    export HTTP_PROXY="${proxyConfig.proxies.http}"
    export HTTPS_PROXY="${proxyConfig.proxies.https}"
    export OPENCODE_DISABLE_LSP_DOWNLOAD="1"
    export COPILOT="1"

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
      KIRO_SYSTEM_PROMPT="**kiro spec dir**: $pr_dir" exec $HOME/.local/bin/opencode --agent kiro "''${args[@]}"
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

  home.sessionVariables = {
    OPENCODE_AUTO_SHARE = "0";
    OPENCODE_DISABLE_AUTOUPDATE = "1";
    OPENCODE_DISABLE_LSP_DOWNLOAD = "1";
  };

  home.activation = {
    setupOpencodeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${config.xdg.configHome}/opencode/
      mkdir -p ${config.home.homeDirectory}/.cache/opencode/

      # Write OpenCode config with MCP servers merged in
      cat ${pkgs.writeText "opencode.jsonc" opencodeConfigJson} > ${config.xdg.configHome}/opencode/opencode.jsonc

      cat ${../../../conf/llm/docs/coding-rules.md} > ${config.xdg.configHome}/opencode/AGENTS.md
      cat ${../../../conf/llm/opencode/package.json} > ${config.xdg.configHome}/opencode/package.json
      cat ${../../../conf/llm/opencode/package.json} > ${config.home.homeDirectory}/.cache/opencode/package.json

      # Setup bunfig.toml with npmmirror registry to avoid proxy issues
      cat > ${config.home.homeDirectory}/.cache/opencode/bunfig.toml << 'EOF'
      [install]
      # Use npmmirror registry for package installation
      registry = "https://registry.npmmirror.com"
      EOF

      cp -rfL ${config.xdg.configHome}/opencode/tool_generated/ ${config.xdg.configHome}/opencode/tool/

      echo "🧕🏻 Opencode config setup done"
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
    "opencode/tool_generated" = {
      source = ../../../conf/llm/opencode/tool;
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
    "opencode/roles/lifeguard.md" = {
      source = ./roles-md/lifeguard-role.md;
    };
  };
}
