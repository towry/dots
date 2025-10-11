{ pkgs, config, ... }:
let
  codex_home = "${config.xdg.configHome}/codex";
  # codex_config_file = "${codex_home}/config.toml";
  # like commands in other agents
  # prompts_dir = "${codex_home}/prompts";
  codex-with-proxy = pkgs.writeShellScriptBin "codex-ai" ''
    export HTTP_PROXY="http://127.0.0.1:1080"
    export HTTPS_PROXY="http://127.0.0.1:1080"

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
    # toml
    "codex/config.toml".text = ''
      model = "openai/gpt-5"
      model_provider = "openrouter"
      approval_policy = "untrusted"
      model_reasoning_effort = "low"
      experimental_instructions_file = "${config.xdg.configHome}/AGENTS.md"

      [model_providers.openrouter]
      name = "openrouter"
      base_url = "https://openrouter.ai/api/v1"
      env_key = "OPENROUTER_API_KEY"

      [profiles.claude]
      model = "openai/gpt-5"
      sandbox_mode = "read-only"
      approval_policy = "never"
      model_provider = "openrouter"
      model_reasoning_effort = "medium"
      model_reasoning_summary = "auto"
      hide_agent_reasoning = true
      model_verbosity = "low"

      [profiles.claude_fast]
      model = "openai/gpt-5-codex"
      sandbox_mode = "read-only"
      approval_policy = "never"
      model_provider = "openrouter"
      model_reasoning_effort = "minimal"
      model_reasoning_summary = "auto"
      hide_agent_reasoning = true
      model_verbosity = "low"

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
      set = { HTTP_PROXY = "http://127.0.0.1:1080", HTTPS_PROXY = "http://127.0.0.1:1080" }

      ## MCP
      [mcp_servers.playwright]
      command = "bunx"
      args = ["@playwright/mcp@latest"]

      [mcp_servers.context7]
      command = "bunx"
      args = ["@upstash/context7-mcp"]

      [mcp_servers.sequential-thinking]
      command = "bunx"
      args = ["@modelcontextprotocol/server-sequential-thinking"]

      [mcp_servers.mermaid]
      command = "bunx"
      args = ["@devstefancho/mermaid-mcp"]

      [mcp_servers.brightdata]
      command = "bunx"
      args = ["@brightdata/mcp"]
      env = { "API_TOKEN" = "${pkgs.nix-priv.keys.brightdata.apiKey}" }

      [mcp_servers.github]
      command = "github-mcp-server"
      args = ["stdio", "--toolsets", "all"]
      env = { GITHUB_PERSONAL_ACCESS_TOKEN = "${pkgs.nix-priv.keys.github.accessToken}" }
    '';
  };
}
