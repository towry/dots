# Some models have region restrictions, like anthropic's Claude models.
# Make sure using http proxy if needed.
# doc: https://docs.litellm.ai/docs/
{
  pkgs,
  config,
  lib,
  ...
}:

let
  proxyConfig = import ../lib/proxy.nix { inherit lib; };

  deepseekModels =
    builtins.map
      (
        model:
        let
          alias = "deepseek/${model}";
        in
        {
          model_name = alias;
          litellm_params = {
            model = alias;
            api_key = "os.environ/DEEPSEEK_API_KEY";
          };
        }
      )
      [
        "deepseek-chat"
      ];

  googleModels =
    builtins.map
      (
        model:
        let
          alias = "gemini/${model}";
        in
        {
          model_name = alias;
          litellm_params = {
            model = alias;
            api_key = "os.environ/GEMINI_API_KEY";
          };
          model_info = {
            base_model = "gemini/${model}";
          };
        }
      )
      [
        "gemini-2.5-pro"
        "gemini-2.5-flash"
      ];

  # Available models from GitHub Copilot API (requires proxy for Claude models)
  # Query: curl -H "Authorization: Bearer $(cat ~/.config/litellm/github_copilot/access-token)" https://api.githubcopilot.com/models
  githubModelNames = [
    # OpenAI models
    "gpt-4o"
    "gpt-4.1"
    "gpt-5"
    "gpt-5-mini"

    # Claude models (require proxy)
    "claude-haiku-4.5"
    "claude-sonnet-4"
    "claude-sonnet-4.5"
    "claude-opus-41"

    # Google models
    "gemini-2.5-pro"

    # xAI models
    "grok-code-fast-1"
  ];

  # GitHub Copilot headers - dynamically use package versions
  copilotHeaders = {
    editor-version = "vscode/${pkgs.vscode.version}";
    editor-plugin-version = "copilot/${pkgs.vscode-extensions.github.copilot.version}";
    Copilot-Integration-Id = "vscode-chat";
    Copilot-Vision-Request = "true";
    user-agent = "GithubCopilot/${pkgs.vscode-extensions.github.copilot.version}";
  };

  githubModels = builtins.map (
    model:
    let
      # Use the model name as-is for the user-facing alias
      alias = "github_copilot/${model}";
    in
    {
      model_name = model; # User calls with just "claude-haiku-4.5"
      litellm_params = {
        model = alias; # LiteLLM uses "github_copilot/claude-haiku-4.5"
        extra_headers = copilotHeaders;
      };
    }
  ) githubModelNames;

  # Zhipu AI models with custom Anthropic-compatible endpoint
  zhipuaiModels =
    builtins.map
      (
        model:
        let
          alias = "zhipuai/${model}";
        in
        {
          model_name = alias;
          litellm_params = {
            model = "openai/${model}"; # Use openai/ prefix for custom endpoint
            api_base = "https://open.bigmodel.cn/api/coding/paas/v4";
            api_key = pkgs.nix-priv.keys.zai.apiKey;
          };
        }
      )
      [
        "glm-4.6"
      ];

  modelList = deepseekModels ++ googleModels ++ githubModels ++ zhipuaiModels;

  litellmConfig = (pkgs.formats.yaml { }).generate "litellm-config.yaml" {
    model_list = modelList;
    litellm_settings = {
      master_key = "os.environ/LITELLM_MASTER_KEY";
      drop_params = true;
      # Disable default log file to avoid conflicts with systemd logging
      # All logs will go to stdout/stderr which systemd captures
      set_verbose = false;
    };
  };

  # Helper script to start LiteLLM proxy
  startLiteLLMScript = pkgs.writeShellScriptBin "litellm-start" ''
    #!/usr/bin/env bash

    # Color codes
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color

    # Check if LITELLM_MASTER_KEY is set
    if [ -z "$LITELLM_MASTER_KEY" ]; then
      echo "Error: LITELLM_MASTER_KEY environment variable is not set"
      echo "Please set it with: export LITELLM_MASTER_KEY=\"sk-<your-key>\""
      exit 1
    fi

    # Display proxy configuration
    if [ -n "$HTTP_PROXY" ] || [ -n "$HTTPS_PROXY" ] || [ -n "$http_proxy" ] || [ -n "$https_proxy" ]; then
      echo -e "''${GREEN}Proxy configuration detected:''${NC}"
      echo -e "  ''${GREEN}HTTP_PROXY:''${NC} ''${HTTP_PROXY:-''${http_proxy:-<not set>}}"
      echo -e "  ''${GREEN}HTTPS_PROXY:''${NC} ''${HTTPS_PROXY:-''${https_proxy:-<not set>}}"
    else
      echo -e "''${YELLOW}Warning:''${NC} No HTTP proxy configured. Claude models may not be accessible."
      echo -e "''${YELLOW}Warning:''${NC} Set HTTP_PROXY/HTTPS_PROXY environment variables if needed."
    fi

    # Start LiteLLM proxy using uvx
    echo "Starting LiteLLM proxy on http://0.0.0.0:4000"
    echo "Using config: ${litellmConfig}"

    # Ensure proxy env vars are exported for LiteLLM
    export HTTP_PROXY="''${HTTP_PROXY:-''${http_proxy}}"
    export HTTPS_PROXY="''${HTTPS_PROXY:-''${https_proxy}}"
    export NO_PROXY="''${NO_PROXY:-''${no_proxy:-${proxyConfig.noProxyString}}}"

    # Install litellm with proxy support (includes httpx[socks])
    ${pkgs.uv}/bin/uvx --with 'litellm[proxy]' --with 'httpx[socks]' litellm --config ${litellmConfig} "$@"
  '';

in
{
  home.packages = [
    # Helper scripts
    startLiteLLMScript
  ];

  # Create a launchd agent for LiteLLM (macOS service)
  # Logs will be written to ~/.local/state/litellm/service.log
  # View logs: tail -f ~/.local/state/litellm/service.log
  # service
  #######
  launchd.agents.litellm = {
    enable = true;
    config = {
      ProgramArguments = [
        "${startLiteLLMScript}/bin/litellm-start"
      ];
      KeepAlive = false;
      RunAtLoad = false;
      StandardOutPath = "${config.xdg.stateHome}/litellm/service.log";
      StandardErrorPath = "${config.xdg.stateHome}/litellm/service.log";
      EnvironmentVariables = {
        LITELLM_MASTER_KEY = pkgs.nix-priv.keys.litellm.apiKey;
        HTTP_PROXY = "http://127.0.0.1:7898";
        HTTPS_PROXY = "http://127.0.0.1:7898";
        NO_PROXY = proxyConfig.noProxyString;
        AIOHTTP_TRUST_ENV = "True";
        PATH = "${pkgs.uv}/bin:${config.home.sessionVariables.PATH or "/usr/bin:/bin"}";
      };
    };
  };

  # Add environment variables for Claude Code integration
  home.sessionVariables = {
    # LiteLLM proxy configuration
    AIOHTTP_TRUST_ENV = "True"; # Enable HTTP(S)_PROXY environment variable support
    LITELLM_MASTER_KEY = pkgs.nix-priv.keys.litellm.apiKey;

    # Point Claude Code to LiteLLM proxy
    ANTHROPIC_BASE_URL = "http://0.0.0.0:4000";
    ANTHROPIC_AUTH_TOKEN = pkgs.nix-priv.keys.litellm.apiKey;

    # Claude Code model selection - configure which models to use for different tiers
    # These map to the model names defined in the LiteLLM config above
    ANTHROPIC_DEFAULT_OPUS_MODEL = "claude-sonnet-4.5"; # For opus tier and opusplan (Plan Mode active)
    ANTHROPIC_DEFAULT_SONNET_MODEL = "claude-sonnet-4.5"; # For sonnet tier and opusplan (Plan Mode inactive)
    ANTHROPIC_DEFAULT_HAIKU_MODEL = "zhipuai/glm-4.6"; # For haiku tier and background tasks
    CLAUDE_CODE_SUBAGENT_MODEL = "zhipuai/glm-4.6"; # For subagents

    # GitHub Copilot token storage (optional customization)
    # GITHUB_COPILOT_TOKEN_DIR = "${config.home.homeDirectory}/.config/litellm/github_copilot";
  };

  # Create a fish function for easy LiteLLM management
  programs.fish.functions = {
    litellm-info = {
      description = "Show LiteLLM configuration info";
      body = ''
        echo "✓ LITELLM_MASTER_KEY configured from nix-priv secrets"
        echo "✓ ANTHROPIC_AUTH_TOKEN configured"
        echo "✓ Claude Code model tiers configured:"
        echo "  - Opus: $ANTHROPIC_DEFAULT_OPUS_MODEL"
        echo "  - Sonnet: $ANTHROPIC_DEFAULT_SONNET_MODEL"
        echo "  - Haiku: $ANTHROPIC_DEFAULT_HAIKU_MODEL"
        echo "  - Subagent: $CLAUDE_CODE_SUBAGENT_MODEL"
        echo ""
        echo "Available commands:"
        echo "  litellm-start          - Start LiteLLM proxy manually"
        echo "  litellm-status         - Check proxy status"
        echo "  litellm-models         - List available models"
        echo "  litellm-test <model>   - Test a specific model"
        echo "  litellm-service-*      - Manage launchd service"
      '';
    };

    litellm-status = {
      description = "Check LiteLLM proxy status";
      body = ''
        set -l response (curl -s http://0.0.0.0:4000/health 2>/dev/null)
        if test $status -eq 0
          echo "✓ LiteLLM proxy is running"
          echo $response | ${pkgs.jq}/bin/jq .
        else
          echo "✗ LiteLLM proxy is not running"
          echo "Start it with: litellm-start"
        end
      '';
    };

    litellm-test = {
      description = "Test LiteLLM proxy";
      body = ''
        # Parse flags
        set -l VERBOSE 0
        set -l MODEL ""
        set -l PROMPT ""

        for arg in $argv
          switch $arg
            case '-V' '--verbose'
              set VERBOSE 1
            case '-*'
              echo "Unknown option: $arg"
              echo "Usage: litellm-test [-V|--verbose] <model> [prompt]"
              return 1
            case '*'
              if test -z "$MODEL"
                set MODEL $arg
              else if test -z "$PROMPT"
                set PROMPT $arg
              end
          end
        end

        if test -z "$MODEL"
          echo "Error: No model specified"
          echo "Usage: litellm-test [-V|--verbose] <model> [prompt]"
          return 1
        end

        if test -z "$PROMPT"
          set PROMPT "Hello!"
        end

        if test -z "$LITELLM_MASTER_KEY"
          echo "Error: LITELLM_MASTER_KEY not set"
          echo "Run: litellm-setup <your-key>"
          return 1
        end

        echo "Testing LiteLLM proxy with model: $MODEL"
        echo "Prompt: $PROMPT"
        echo ""
        echo "--- Request ---"
        echo "POST http://0.0.0.0:4000/v1/chat/completions"
        echo "Model: $MODEL"
        echo ""

        # Build curl command with optional verbose flag
        set -l curl_args
        if test $VERBOSE -eq 1
          set curl_args -v
        else
          set curl_args -s
        end

        # Don't use proxy for localhost connections
        env no_proxy="${proxyConfig.noProxyString}" \
        curl $curl_args -X POST http://0.0.0.0:4000/v1/chat/completions \
          -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
          -H "Content-Type: application/json" \
          -d "{\"model\": \"$MODEL\", \"messages\": [{\"role\": \"user\", \"content\": \"$PROMPT\"}]}" \
          2>&1
      '';
    };

    litellm-models = {
      description = "List available LiteLLM models";
      body = ''
        if test -z "$LITELLM_MASTER_KEY"
          echo "Error: LITELLM_MASTER_KEY not set"
          echo "Run: litellm-setup <your-key>"
          return 1
        end

        curl -s http://0.0.0.0:4000/v1/models \
          -H "Authorization: Bearer $LITELLM_MASTER_KEY" | ${pkgs.jq}/bin/jq .
      '';
    };

    # Launchd service management functions (macOS)
    litellm-service-start = {
      description = "Start LiteLLM launchd agent";
      body = ''
        # Ensure log directory exists
        mkdir -p ~/.local/state/litellm

        # Load the service if not already loaded
        launchctl bootstrap gui/(id -u) ~/Library/LaunchAgents/org.nix-community.home.litellm.plist 2>/dev/null
        or launchctl load ~/Library/LaunchAgents/org.nix-community.home.litellm.plist 2>/dev/null

        # Start the service (since RunAtLoad is false, it won't start automatically)
        launchctl start org.nix-community.home.litellm

        echo "✓ LiteLLM service started"
        echo "View logs: litellm-service-logs"
      '';
    };

    litellm-service-stop = {
      description = "Stop LiteLLM launchd agent";
      body = ''
        # Stop the running service first
        launchctl stop org.nix-community.home.litellm 2>/dev/null

        # Then unload it
        launchctl bootout gui/(id -u)/org.nix-community.home.litellm 2>/dev/null
        or launchctl unload ~/Library/LaunchAgents/org.nix-community.home.litellm.plist 2>/dev/null

        echo "✓ LiteLLM service stopped"
      '';
    };

    litellm-service-restart = {
      description = "Restart LiteLLM launchd agent";
      body = ''
        litellm-service-stop
        sleep 1
        litellm-service-start
        echo "✓ LiteLLM service restarted"
      '';
    };

    litellm-service-status = {
      description = "Check LiteLLM launchd agent status";
      body = ''
        launchctl list | grep litellm
        if test $status -eq 0
          echo ""
          echo "✓ LiteLLM service is loaded"
        else
          echo "✗ LiteLLM service is not loaded"
        end
      '';
    };

    litellm-service-logs = {
      description = "View LiteLLM launchd agent logs";
      body = ''
        set -l log_file ~/.local/state/litellm/service.log
        if test -f $log_file
          tail -n 100 -f $log_file
        else
          echo "Log file not found: $log_file"
          echo "Make sure the service has been started at least once"
        end
      '';
    };
  };

  # Add configuration file to home directory for reference
  home.file.".config/litellm/config.yaml".source = litellmConfig;
}
