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
          maxTokens = modelMaxTokens."deepseek-chat" or 8192;
        in
        {
          model_name = alias;
          litellm_params = {
            model = alias;
            api_key = "os.environ/DEEPSEEK_API_KEY";
            max_tokens = maxTokens;
            max_output_tokens = maxTokens;
          };
        }
      )
      [
        "deepseek-chat"
      ];
  openrouterModels = [
    {
      model_name = "openrouter/*";
      litellm_params = {
        model = "openrouter/*";
        api_key = "os.environ/OPENROUTER_API_KEY";

        cache_control_injection_points = [
          {
            location = "message";
            role = "user";
          }
        ];
      };
    }
  ];

  googleModels =
    builtins.map
      (
        model:
        let
          alias = "gemini/${model}";
          maxTokens = modelMaxTokens."${alias}" or (modelMaxTokens."${model}" or 65536);
        in
        {
          model_name = alias;
          litellm_params = {
            model = alias;
            max_tokens = maxTokens;
            max_output_tokens = maxTokens;
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

    # copilot fine-tuned gpt-5-mini
    "oswe-vscode-prime"
  ];

  modelMaxTokens = {
    # OpenAI models
    "openai/gpt-5" = 128000;
    "openai/gpt-5-mini" = 128000;
    "openai/gpt-4.1" = 32768;
    "openai/gpt-4o" = 16384;
    "gpt-5" = 128000;
    "gpt-5-mini" = 128000;
    "gpt-4.1" = 32768;
    "gpt-4o" = 16384;

    # GitHub Copilot models (use github-copilot provider from models.dev)
    "github_copilot/gpt-5" = 128000;
    "github_copilot/gpt-5-mini" = 128000;
    "github_copilot/gpt-4.1" = 32768;
    "github_copilot/gpt-4o" = 16384;
    "github_copilot/claude-haiku-4.5" = 64000;
    "github_copilot/claude-sonnet-4" = 64000;
    "github_copilot/claude-sonnet-4.5" = 64000;
    "github_copilot/claude-opus-41" = 16000;
    "github_copilot/gemini-2.5-pro" = 65536;
    "github_copilot/gemini-2.5-flash" = 65536;
    "github_copilot/grok-code-fast-1" = 10000;
    "github_copilot/oswe-vscode-prime" = 64000;

    # Claude models
    "anthropic/claude-haiku-4.5" = 64000;
    "anthropic/claude-sonnet-4" = 64000;
    "anthropic/claude-sonnet-4.5" = 64000;
    "claude-haiku-4.5" = 64000;
    "claude-sonnet-4" = 64000;
    "claude-sonnet-4.5" = 64000;
    "claude-opus-41" = 16000;

    # Google models
    "google/gemini-2.5-pro" = 65536;
    "google/gemini-2.5-flash" = 65536;
    "gemini-2.5-pro" = 65536;
    "gemini-2.5-flash" = 65536;

    # xAI models
    "xai/grok-code-fast-1" = 10000;
    "grok-code-fast-1" = 10000;

    # DeepSeek models
    "deepseek/deepseek-chat" = 8192;
    "deepseek-chat" = 8192;

    # Zhipu AI models (Z.AI Coding Plan)
    "zai-coding-plan/glm-4.6" = 131072;
    "zai-coding-plan/glm-4.5-air" = 98304;
    "glm-4.6" = 131072;
    "glm-4.5-air" = 98304;

    # Kimi models (Moonshot AI)
    "moonshotai/kimi-k2-thinking" = 262144;
    "moonshotai-cn/kimi-k2-thinking" = 262144;
    "kimi-k2-thinking" = 262144;

    # GitHub Copilot specific entries
    "oswe-vscode-prime" = 64000;
  };

  # helper functions to extract model key from names like "copilot/gpt-5", "openai/gpt-5" and return the max token
  getModelKey =
    m:
    let
      toks = builtins.splitString "/" (toString m);
    in
    builtins.elemAt toks (builtins.length toks - 1);
  modelTokenMax =
    m:
    let
      fullKey = toString m;
      shortKey = getModelKey m;
    in
    # Try full key first (e.g., "github_copilot/gpt-5"), then fall back to short key (e.g., "gpt-5")
    if lib.hasAttr fullKey modelMaxTokens then
      builtins.getAttr fullKey modelMaxTokens
    else if lib.hasAttr shortKey modelMaxTokens then
      builtins.getAttr shortKey modelMaxTokens
    else
      8192; # Conservative fallback

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
      maxTokens = modelMaxTokens."${alias}" or (modelMaxTokens."${model}" or 8192);
    in
    {
      model_name = "copilot/${model}"; # User calls with just "claude-haiku-4.5"
      litellm_params = {
        model = alias; # LiteLLM uses "github_copilot/claude-haiku-4.5"
        extra_headers = copilotHeaders;
        max_tokens = maxTokens;
        max_output_tokens = maxTokens;
        cache_control_injection_points = [
          {
            location = "message";
            role = "user";
          }
        ];
      };
    }
  ) githubModelNames;

  copilotGpt5Model = [
    {
      model_name = "gpt-5";
      litellm_params = {
        model = "github_copilot/gpt-5";
        extra_headers = copilotHeaders;
        cache_control_injection_points = [
          {
            location = "message";
            role = "user";
          }
        ];
        max_tokens = 128000;
        max_output_tokens = 128000;
      };
    }
  ];

  # Zhipu AI models with custom Anthropic-compatible endpoint
  zhipuaiModels =
    builtins.map
      (
        model:
        let
          alias = "zhipuai/${model}";
          # zhipuai uses "openai/${model}" as the actual model value, check both
          maxTokens = modelMaxTokens."openai/${model}" or (modelMaxTokens."${model}" or 131072);
        in
        {
          model_name = alias;
          litellm_params = {
            model = "openai/${model}"; # Use openai/ prefix for custom endpoint
            api_base = "https://open.bigmodel.cn/api/coding/paas/v4";
            api_key = pkgs.nix-priv.keys.zai.apiKey;
            max_tokens = maxTokens;
            max_output_tokens = maxTokens;
          };
        }
      )
      [
        "glm-4.6"
        "glm-4.5-air"
      ];

  kimiModels =
    builtins.map
      (
        model:
        let
          alias = "kimi/${model}";
          # kimi uses "openai/${model}" as the actual model value
          maxTokens = modelMaxTokens."openai/${model}" or (modelMaxTokens."${model}" or 262144);
        in
        {
          model_name = alias;
          litellm_params = {
            model = "openai/${model}";
            api_base = "https://api.kimi.com/coding/v1";
            api_key = "${pkgs.nix-priv.keys.kimi.apiKey}";
            reasoning_effort = "medium";
            max_tokens = maxTokens;
            max_output_tokens = maxTokens;
          };
        }
      )
      [
        "${pkgs.nix-priv.keys.kimi.kimiForCodingModel}"
      ];

  moonshotThinkingModels = [
    {
      model_name = "moonshot/kimi-k2-thinking"; # Alias user will call
      litellm_params = {
        model = "moonshot/kimi-k2-thinking";
        api_base = "https://api.moonshot.cn/v1";
        api_key = "${pkgs.nix-priv.keys.moonshot.apiKey}";
        max_tokens = 262144;
        max_output_tokens = 262144;
      };
    }
  ];

  modelList =
    deepseekModels
    ++ googleModels
    ++ githubModels
    ++ copilotGpt5Model
    ++ zhipuaiModels
    ++ openrouterModels
    ++ kimiModels
    ++ moonshotThinkingModels;

  litellmConfig = (pkgs.formats.yaml { }).generate "litellm-config.yaml" {
    model_list = modelList;
    litellm_settings = {
      default_fallbacks = [ "openrouter/x-ai/grok-4-fast" ];
      master_key = "os.environ/LITELLM_MASTER_KEY";
      drop_params = true;
      # Disable default log file to avoid conflicts with systemd logging
      # All logs will go to stdout/stderr which systemd captures
      # set_verbose deprecated upstream; prefer environment variable LITELLM_LOG=DEBUG
      turn_off_message_logging = true;
      # Enable custom vision router hook
      # LiteLLM will load this from ~/.config/litellm/ directory
      callbacks = "conf.llm.litellm_vision_router.vision_router_instance";
      # Generic fallbacks (covers remaining error types incl. BadRequestError if not mapped)
      fallbacks = [
        { "copilot/claude-haiku-4.5" = [ "openrouter/openai/gpt-5-mini" ]; }
      ];
      cache = true;
      cache_params = {
        namespace = "litellm.caching.caching";
        type = "redis";
        host = "${pkgs.nix-priv.keys.litellm.redisHost}";
        port = pkgs.nix-priv.keys.litellm.redisPort;
        password = "${pkgs.nix-priv.keys.litellm.redisPass}";
      };
    };
    router_settings = {
      num_retries = 1;
      allowed_fails = 3;
      cooldown_time = 180;
      # Token counting during pre-call checks can fail for some clients that send
      # non-standard message content shapes (e.g. sending a single dict instead of
      # a list of content parts for vision messages). This triggers errors like:
      # "failed to count tokens ... Invalid content type: <class 'dict'>"
      # Disable pre-call token counting to avoid hard failures; rely on provider
      # context-window errors + configured context_window_fallbacks instead.
      enable_pre_call_checks = false;
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

    # Start LiteLLM proxy using the Nix package
    echo "Starting LiteLLM proxy on http://0.0.0.0:4000"
    echo "Using config: ${config.home.homeDirectory}/.config/litellm/config.yaml"
    echo -e "''${GREEN}Vision routing enabled:''${NC} conf.llm.litellm_vision_router"

    # Ensure proxy env vars are exported for LiteLLM
    export HTTP_PROXY="''${HTTP_PROXY:-''${http_proxy}}"
    export HTTPS_PROXY="''${HTTPS_PROXY:-''${https_proxy}}"
    export NO_PROXY="''${NO_PROXY:-''${no_proxy:-${proxyConfig.noProxyString}}}"

    # Add ~/.config/litellm to PYTHONPATH so LiteLLM can load the vision router
    export PYTHONPATH="${config.home.homeDirectory}/.config/litellm:''${PYTHONPATH:-}"

    # Use the Nix-built litellm package
    ${pkgs.litellm-proxy}/bin/litellm --config ${config.home.homeDirectory}/.config/litellm/config.yaml "$@"
  '';

in
{
  home.packages = [
    pkgs.litellm-proxy
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
        # Use new logging control instead of deprecated set_verbose
        # LITELLM_LOG = "DEBUG";
        # Provide provider API keys directly to the service
        OPENROUTER_API_KEY = pkgs.nix-priv.keys.openrouter.apiKey;
        HTTP_PROXY = proxyConfig.proxies.http;
        HTTPS_PROXY = proxyConfig.proxies.http;
        NO_PROXY = proxyConfig.noProxyString;
        AIOHTTP_TRUST_ENV = "True";
        PYTHONPATH = "${config.home.homeDirectory}/.config/litellm";
        PATH = "${pkgs.litellm-proxy}/bin:${config.home.sessionVariables.PATH or "/usr/bin:/bin"}";
      };
    };
  };

  # Add environment variables for Claude Code integration
  home.sessionVariables = {
    # LiteLLM proxy configuration
    AIOHTTP_TRUST_ENV = "True"; # Enable HTTP(S)_PROXY environment variable support
    LITELLM_MASTER_KEY = pkgs.nix-priv.keys.litellm.apiKey;
    # Optional per-shell override of log level (can be INFO to reduce noise)
    LITELLM_LOG = "INFO";
    # Make OpenRouter key available to interactive shell usage of litellm-start/litellm-test
    OPENROUTER_API_KEY = pkgs.nix-priv.keys.openrouter.apiKey;

    # Point Claude Code to LiteLLM proxy
    ANTHROPIC_BASE_URL = "http://0.0.0.0:4000";
    ANTHROPIC_AUTH_TOKEN = pkgs.nix-priv.keys.litellm.apiKey;

    # Claude Code model selection - configure which models to use for different tiers
    # These map to the model names defined in the LiteLLM config above
    ANTHROPIC_DEFAULT_OPUS_MODEL = "copilot/gpt-5"; # For opus tier and opusplan (Plan Mode active)
    ANTHROPIC_DEFAULT_SONNET_MODEL = "copilot/oswe-vscode-prime"; # For sonnet tier and opusplan (Plan Mode inactive)
    ANTHROPIC_DEFAULT_HAIKU_MODEL = "copilot/oswe-vscode-prime"; # For haiku tier and background tasks
    ## do not set this variable, otherwise the `model` will not work.
    # CLAUDE_CODE_SUBAGENT_MODEL = "openrouter/google/gemini-2.5-pro"; # For subagent# s

    # GitHub Copilot token storage (optional customization)
    # GITHUB_COPILOT_TOKEN_DIR = "${config.home.homeDirectory}/.config/litellm/github_copilot";
  };

  # Create a fish function for easy LiteLLM management
  programs.fish.functions = {
    litellm-info = {
      description = "Show LiteLLM configuration info";
      body = ''
        echo "✓ LITELLM_MASTER_KEY configured from nix-priv secrets"
        if test -n "$OPENROUTER_API_KEY"
          echo "✓ OPENROUTER_API_KEY configured"
        else
          echo "✗ OPENROUTER_API_KEY missing for OpenRouter models"
        end
        echo "✓ ANTHROPIC_AUTH_TOKEN configured"
        echo "✓ Claude Code model tiers configured:"
        echo "  - Opus: $ANTHROPIC_DEFAULT_OPUS_MODEL"
        echo "  - Sonnet: $ANTHROPIC_DEFAULT_SONNET_MODEL"
        echo "  - Haiku: $ANTHROPIC_DEFAULT_HAIKU_MODEL"
        echo "  - Subagent: $CLAUDE_CODE_SUBAGENT_MODEL"
        echo ""
        echo "LiteLLM log level: $LITELLM_LOG (set via env, replaces deprecated set_verbose)"
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

  # Add configuration files to home directory
  home.file = {
    ".config/litellm/config.yaml".source = litellmConfig;

    # Vision router module - LiteLLM loads callbacks relative to config directory
    ".config/litellm/conf/__init__.py".text = ''"""Configuration files package."""'';
    ".config/litellm/conf/llm/__init__.py".text = ''"""LLM configuration and utilities package."""'';
    ".config/litellm/conf/llm/litellm_vision_router.py".source =
      pkgs.nix-priv.scripts.litellmVisionRouter;
  };
}
