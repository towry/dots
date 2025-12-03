{
  pkgs,
  config,
  lib,
  ...
}:
let
  proxyConfig = import ../../../lib/proxy.nix { inherit lib pkgs; };
  codex_home = "${config.xdg.configHome}/codex";
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
    # toml
    "codex/config.toml".text = ''
      model = "gpt-5"
      model_provider = "litellm"
      approval_policy = "untrusted"
      model_reasoning_effort = "low"
      # the AGENTS.md contains instructions for using codex mcp, do not use it
      # experimental_instructions_file = "${config.xdg.configHome}/AGENTS.md"
      sandbox_mode = "read-only"

      [model_providers.litellm]
      name = "litellm"
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
      model = "copilot/gpt-5"
      model_provider = "litellm"
      sandbox_mode = "read-only"
      experimental_instructions_file = "${codex_home}/instructions/oracle-role.md"
      approval_policy = "never"
      model_reasoning_effort = "medium"
      model_reasoning_summary = "concise"
      hide_agent_reasoning = true
      model_verbosity = "low"

      [profiles.chromedev]
      model = "openai/gpt-5.1-codex-mini"
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

      [profiles.sage_slow]
      model = "glm-4.6"
      model_provider = "zhipuai-coding-plan"
      sandbox_mode = "read-only"
      experimental_instructions_file = "${codex_home}/instructions/sage-role.md"
      approval_policy = "never"
      model_reasoning_effort = "medium"
      model_reasoning_summary = "concise"
      hide_agent_reasoning = true
      model_verbosity = "low"

      [profiles.sage]
      model = "kimi-k2-turbo-preview"
      model_provider = "moonshot"
      sandbox_mode = "read-only"
      experimental_instructions_file = "${codex_home}/instructions/sage-role.md"
      approval_policy = "never"
      model_reasoning_effort = "low"
      model_reasoning_summary = "concise"
      hide_agent_reasoning = true
      model_verbosity = "medium"

      [tui]
      # notifications = [ "agent-turn-complete", "approval-requested" ]
      notifications = true

      [shell_environment_policy]
      inherit = "core"
      ignore_default_excludes = true
      # ["AWS_*"]
      exclude = []
      # if provided, *only* vars matching these patterns are kept
      include_only = []
      set = { HTTP_PROXY = "${proxyConfig.proxies.http}", HTTPS_PROXY = "${proxyConfig.proxies.https}" }

      ## MCP
      [mcp_servers.chromedev]
      command = "bunx"
      args = ["chrome-devtools-mcp@latest", "--browser-url=http://127.0.0.1:9222"]

      # [mcp_servers.context7]
      # command = "bunx"
      # args = ["@upstash/context7-mcp"]

      # [mcp_servers.mermaid]
      # command = "bunx"
      # args = ["@devstefancho/mermaid-mcp"]

      # [mcp_servers.sequentialthinking]
      # command = "bunx"
      # args = ["@modelcontextprotocol/server-sequential-thinking"]

      # [mcp_servers.github]
      # command = "github-mcp-server"
      # args = ["stdio", "--dynamic-toolsets"]
      # env = { GITHUB_PERSONAL_ACCESS_TOKEN = "${pkgs.nix-priv.keys.github.accessToken}" }
    '';
  };
}
