{
  pkgs,
  config,
  lib,
  ...
}:
let
  proxyConfig = import ../../../lib/proxy.nix { inherit lib pkgs; };
  mcp = import ../../../modules/ai/mcp.nix { inherit pkgs lib config; };
  codex_home = "${config.xdg.configHome}/codex";
  codexMcpToml = builtins.readFile (
    (pkgs.formats.toml { }).generate "codex-mcp.toml" { mcp_servers = mcp.clients.codex; }
  );
  # codex_config_file = "${codex_home}/config.toml";
  # like commands in other agents
  # prompts_dir = "${codex_home}/prompts";
  codex-with-proxy = pkgs.writeShellScriptBin "codex-ai" ''
    export HTTP_PROXY="${proxyConfig.proxies.http}"
    export HTTPS_PROXY="${proxyConfig.proxies.https}"

    exec codex "$@"
  '';
in
{
  home.sessionVariables = {
    CODEX_HOME = codex_home;
  };
  home.packages = [
    codex-with-proxy
  ];

  xdg.configFile = {
    "codex/instructions" = {
      source = ./instructions;
      recursive = true;
    };
    "codex/skills" = {
      source = ../../../../conf/claude-local-marketplace/skills;
      recursive = true;
    };
    # toml
    "codex/config-generated.toml".text = ''
      model = "gpt-5.2-medium"
      model_provider = "packy"
      approval_policy = "on-failure"
      model_reasoning_effort = "medium"
      # the AGENTS.md contains instructions for using codex mcp, do not use it
      # experimental_instructions_file = "${config.xdg.configHome}/AGENTS.md"
      project_doc_fallback_filenames = ["CLAUDE.md"]
      sandbox_mode = "workspace-write"

      [features]
      tui2 = true
      skills = true
      unified_exec = true
      apply_patch_freeform = true
      view_image_tool = false
      ghost_commit = false

      [model_providers.packy]
      name = "packy"
      wire_api = "responses"
      base_url = "https://www.packyapi.com/v1"
      env_key = "PACKYCODE_CODEX_API_KEY"

      [model_providers.litellm]
      name = "litellm"
      wire_api = "responses"
      base_url = "http://127.0.0.1:4000"
      env_key = "LITELLM_MASTER_KEY"

      [model_providers.openrouter]
      name = "openrouter"
      base_url = "https://openrouter.ai/api/v1"
      env_key = "OPENROUTER_API_KEY"

      [model_providers.zhipuai-coding-plan]
      name = "zhipuai-coding-plan"
      base_url = "https://open.bigmodel.cn/api/coding/paas/v4"
      env_key = "ZAI_API_KEY"

      [model_providers.moonshot]
      name = "moonshot"
      base_url = "https://api.moonshot.cn/v1"
      env_key = "MOONSHOT_API_KEY"

      [profiles.gpt]
      model = "zenmux/openai/gpt-5.1-codex-mini"
      model_provider = "litellm"
      sandbox_mode = "read-only"
      experimental_instructions_file = "${codex_home}/instructions/oracle-role.md"
      approval_policy = "never"
      model_reasoning_effort = "medium"
      model_reasoning_summary = "concise"
      hide_agent_reasoning = true
      model_verbosity = "low"

      [profiles.chromedev]
      model = "google/gemini-2.5-flash"
      model_provider = "openrouter"
      sandbox_mode = "read-only"
      experimental_instructions_file = "${codex_home}/instructions/chromedev.md"
      approval_policy = "never"
      model_reasoning_effort = "medium"
      model_reasoning_summary = "concise"
      hide_agent_reasoning = true
      model_verbosity = "low"

      [profiles.claude]
      model = "copilot/claude-sonnet-4.5"
      model_provider = "litellm"
      sandbox_mode = "read-only"
      experimental_instructions_file = "${codex_home}/instructions/oracle-role.md"
      approval_policy = "never"
      model_reasoning_effort = "high"
      model_reasoning_summary = "concise"
      hide_agent_reasoning = true
      model_verbosity = "low"

      [profiles.review]
      model = "glm-4.6"
      model_provider = "zhipuai-coding-plan"
      sandbox_mode = "read-only"
      experimental_instructions_file = "${codex_home}/instructions/review-role.md"
      approval_policy = "never"
      model_reasoning_effort = "medium"
      model_reasoning_summary = "concise"
      hide_agent_reasoning = true
      model_verbosity = "low"

      [tui]
      # notifications = [ "agent-turn-complete", "approval-requested" ]
      notifications = true
      animations = false
      scroll_events_per_tick = 3
      scroll_wheel_lines = 3
      scroll_mode = "auto"

      [sandbox_workspace_write]
      network_access = true
      writable_roots = ["${config.home.homeDirectory}/workspace/work"]

      [shell_environment_policy]
      inherit = "core"
      ignore_default_excludes = true
      # ["AWS_*"]
      exclude = []
      # if provided, *only* vars matching these patterns are kept
      include_only = []
      set = { HTTP_PROXY = "${proxyConfig.proxies.http}", HTTPS_PROXY = "${proxyConfig.proxies.https}" }

      ## MCP
      ${codexMcpToml}
    '';
  };

  home.activation = {
    setupCodexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      CODEX_HOME="${codex_home}"

      cp -f ${codex_home}/config-generated.toml "${codex_home}/config.toml"
      chmod u+w "${codex_home}/config.toml"

      cat ${../../../../conf/llm/docs/coding-rules.md} > ${codex_home}/AGENTS.md
    '';
  };
}
