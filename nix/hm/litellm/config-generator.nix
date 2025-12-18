# Shared LiteLLM config generator
# Used by both home-manager module and CI/CD builds
{ pkgs, lib }:

let
  proxyConfig = import ../../lib/proxy.nix { inherit lib pkgs; };

  # Import model token limits module
  tokenModule = import ./model-tokens.nix { inherit lib; };
  inherit (tokenModule) getMaxInputTokens getMaxOutputTokens getMaxTokens;

  # GitHub Copilot headers
  copilotHeaders = {
    Editor-Version = "vscode/${pkgs.vscode.version}";
    editor-plugin-version = "copilot/${pkgs.vscode-extensions.github.copilot.version}";
    Copilot-Integration-Id = "vscode-chat";
    Copilot-Vision-Request = "true";
    user-agent = "GithubCopilot/${pkgs.vscode-extensions.github.copilot.version}";
  };

  # Import all model configurations (keeping your existing logic)
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
            stream = true;
          };
        }
      )
      [
        "deepseek-chat"
        "deepseek-reasoner"
      ];

  mistralModels =
    builtins.map
      (
        model:
        let
          alias = "mistral/${model}";
          maxOutputTokens = getMaxOutputTokens "mistral/${model}";
        in
        {
          model_name = alias;
          litellm_params = {
            model = alias;
            api_key = pkgs.nix-priv.keys.mistra.apiKey;
            max_tokens = maxOutputTokens;
          };
        }
      )
      [
        "codestral-2508"
        "devstral-2512"
      ];

  aliCnModels =
    builtins.map
      (
        model:
        let
          alias = "dashscope/${model}";
          maxOutputTokens = getMaxOutputTokens "dashscope/${model}";
        in
        {
          model_name = alias;
          litellm_params = {
            model = alias;
            api_key = pkgs.nix-priv.keys.alimodel.apiKey;
            api_base = "https://dashscope.aliyuncs.com/compatible-mode/v1";
          };
          model_info = {
            max_output_tokens = maxOutputTokens;
          };
        }
      )
      [
        "qwen3-coder-plus"
        "qwen3-coder-480b-a35b-instruct"
        "qwen3-max"
      ];

  openrouterModels = [
    {
      model_name = "openrouter/mistral-large-2512";
      litellm_params = {
        model = "openrouter/mistralai/mistral-large-2512";
        api_key = pkgs.nix-priv.keys.openrouter.apiKey;
        max_tokens = 252000;
      };
    }
    {
      model_name = "openrouter/devstral-2512";
      litellm_params = {
        model = "openrouter/mistralai/devstral-2512:free";
        api_key = pkgs.nix-priv.keys.openrouter.apiKey;
        max_tokens = 252000;
      };
    }
    {
      model_name = "openrouter/*";
      litellm_params = {
        model = "openrouter/*";
        api_key = pkgs.nix-priv.keys.openrouter.apiKey;
      };
    }
  ];

  googleModels =
    builtins.map
      (
        model:
        let
          alias = "gemini/${model}";
          maxOutputTokens = getMaxOutputTokens "google/${model}";
        in
        {
          model_name = alias;
          litellm_params = {
            model = alias;
            max_tokens = maxOutputTokens;
            max_output_tokens = maxOutputTokens;
            api_key = "os.environ/GEMINI_API_KEY";
          };
          model_info = {
            base_model = "gemini/${model}";
            max_output_tokens = maxOutputTokens;
          };
        }
      )
      [
        "gemini-2.5-pro"
        "gemini-2.5-flash"
      ];

  githubModelNames = [
    "gpt-4o"
    "gpt-4.1"
    "gpt-5"
    "gpt-5-mini"
    "gpt-5-codex"
    "gpt-5.1-codex-mini"
    "gpt-5.1"
    "gpt-5.1-codex"
    "claude-haiku-4.5"
    "claude-sonnet-4"
    "claude-sonnet-4.5"
    "claude-opus-41"
    "gemini-2.5-pro"
    "gemini-3-pro-preview"
    "grok-code-fast-1"
    "oswe-vscode-prime"
  ];

  githubModels = builtins.map (
    model:
    let
      alias = "github_copilot/${model}";
      maxOutputTokens = getMaxOutputTokens "github_copilot/${model}";
    in
    {
      model_name = "copilot/${model}";
      model_info = {
        supports_vision = true;
        max_output_tokens = maxOutputTokens;
      };
      litellm_params = {
        model = alias;
        extra_headers = copilotHeaders;
        max_tokens = maxOutputTokens;
      };
    }
  ) githubModelNames;

  copilotGpt5Model = [
    {
      model_name = "gpt-5";
      litellm_params = {
        model = "github_copilot/gpt-5";
        extra_headers = copilotHeaders;
        max_tokens = getMaxOutputTokens "github_copilot/gpt-5";
      };
      model_info = {
        max_output_tokens = getMaxOutputTokens "github_copilot/gpt-5";
      };
    }
  ];

  opencodeModels =
    builtins.map
      (
        model:
        let
          alias = "opencodeai/${model}";
          maxOutputTokens = getMaxOutputTokens "opencodeai/${model}";
        in
        {
          model_name = alias;
          litellm_params = {
            model = "openai/${model}";
            api_base = "https://opencode.ai/zen/v1";
            api_key = pkgs.nix-priv.keys.opencode.apiKey;
            max_tokens = maxOutputTokens;
          };
          model_info = {
            max_output_tokens = maxOutputTokens;
          };
        }
      )
      [
        "gpt-5"
        "gpt-5.1"
        "gpt-5.1-codex"
        "gpt-5.1-codex-max"
        "gpt-5-nano"
        "claude-sonnet-4-5"
        "claude-haiku-4-5"
        "claude-3-5-haiku"
        "gemini-3-pro"
        "gemini-3-flash"
        "qwen3-coder"
        "kimi-k2"
        "kimi-k2-thinking"
        "big-pickle"
        "grok-code"
      ];

  zhipuaiModels =
    builtins.map
      (
        model:
        let
          alias = "zhipuai/${model}";
          maxOutputTokens = getMaxOutputTokens "zhipuai/${model}";
        in
        {
          model_name = alias;
          litellm_params = {
            model = "openai/${model}";
            api_base = "https://open.bigmodel.cn/api/coding/paas/v4";
            api_key = pkgs.nix-priv.keys.zai.apiKey;
            max_tokens = maxOutputTokens;
            max_output_tokens = maxOutputTokens;
          };
          model_info = {
            max_output_tokens = maxOutputTokens;
          };
        }
      )
      [
        "glm-4.6"
        "glm-4.5-air"
        "glm-4.5-flash"
      ];

  kimiModels =
    builtins.map
      (
        model:
        let
          alias = "kimi/${model}";
          maxOutputTokens = getMaxOutputTokens "moonshot/kimi-k2-thinking";
        in
        {
          model_name = alias;
          litellm_params = {
            model = "openai/${model}";
            api_base = "https://api.kimi.com/coding/v1";
            api_key = "${pkgs.nix-priv.keys.kimi.apiKey}";
            reasoning_effort = "medium";
            max_tokens = maxOutputTokens;
            max_output_tokens = maxOutputTokens;
          };
          model_info = {
            max_output_tokens = maxOutputTokens;
          };
        }
      )
      [
        "${pkgs.nix-priv.keys.kimi.kimiForCodingModel}"
      ];

  moonshotThinkingModels = [
    {
      model_name = "moonshot/kimi-k2";
      litellm_params = {
        model = "moonshot/kimi-k2-0905-preview";
        api_base = "https://api.moonshot.cn/v1";
        api_key = "${pkgs.nix-priv.keys.moonshot.apiKey}";
        max_tokens = getMaxOutputTokens "moonshot/kimi-k2-thinking";
        max_output_tokens = getMaxOutputTokens "moonshot/kimi-k2-thinking";
      };
      model_info = {
        max_output_tokens = getMaxOutputTokens "moonshot/kimi-k2-thinking";
      };
    }
    {
      model_name = "moonshot/kimi-k2-thinking";
      litellm_params = {
        model = "moonshot/kimi-k2-thinking";
        api_base = "https://api.moonshot.cn/v1";
        api_key = "${pkgs.nix-priv.keys.moonshot.apiKey}";
        max_tokens = getMaxOutputTokens "moonshot/kimi-k2-thinking";
        max_output_tokens = getMaxOutputTokens "moonshot/kimi-k2-thinking";
      };
      model_info = {
        max_output_tokens = getMaxOutputTokens "moonshot/kimi-k2-thinking";
      };
    }
  ];

  # Import model group modules
  benderMuffinModels = import ./bender-muffin.nix {
    inherit pkgs copilotHeaders;
    inherit (tokenModule) getMaxInputTokens getMaxOutputTokens getMaxTokens;
  };

  freeMuffinModels = import ./free-muffin.nix {
    inherit pkgs copilotHeaders;
    inherit (tokenModule) getMaxInputTokens getMaxOutputTokens getMaxTokens;
  };

  frontierMuffinModels = import ./frontier-muffin.nix {
    inherit pkgs copilotHeaders;
    inherit (tokenModule) getMaxInputTokens getMaxOutputTokens getMaxTokens;
  };

  # Combine all models
  modelList =
    deepseekModels
    ++ mistralModels
    ++ googleModels
    ++ githubModels
    ++ copilotGpt5Model
    ++ zhipuaiModels
    ++ openrouterModels
    ++ kimiModels
    ++ moonshotThinkingModels
    ++ benderMuffinModels
    ++ freeMuffinModels
    ++ frontierMuffinModels
    ++ opencodeModels
    ++ aliCnModels;

in
{
  # Export model list and config structure
  inherit modelList copilotHeaders;

  # Generate the complete config
  config = {
    model_list = modelList;
    litellm_settings = {
      REPEATED_STREAMING_CHUNK_LIMIT = 100;
      image_generation_model = "openrouter/x-ai/grok-4-fast";
      master_key = "os.environ/LITELLM_MASTER_KEY";
      request_timeout = 600;
      num_retries = 2;
      allowed_fails = 3;
      cooldown_time = 30;
      drop_params = true;
      json_logs = false;
      turn_off_message_logging = true;
      fallbacks = [
        { "copilot/claude-haiku-4.5" = [ "opencodeai/claude-haiku-4-5" ]; }
        { "copilot/claude-sonnet-4.5" = [ "opencodeai/claude-sonnet-4.5" ]; }
        { "copilot/gpt-5-mini" = [ "openrouter/minimax/minimax-m2" ]; }
        { "openai/minimax-m2" = [ "opencodeai/claude-haiku-4-5" ]; }
        { "bender-muffin" = [ "opencodeai/claude-haiku-4-5" ]; }
      ];
      cache = false;
      cache_params = {
        namespace = "litellm.caching.caching";
        type = "redis";
        host = "${pkgs.nix-priv.keys.litellm.redisHost}";
        port = pkgs.nix-priv.keys.litellm.redisPort;
        password = "${pkgs.nix-priv.keys.litellm.redisPass}";
        ttl = 3600;
        socket_timeout = 20;
        socket_connect_timeout = 20;
      };
      disable_copilot_system_to_assistant = true;
      enable_json_schema_validation = true;
    };
    general_settings = {
      health_check_interval = 300;
    };
    router_settings = {
      num_retries = 2;
      allowed_fails = 3;
      cooldown_time = 30;
      routing_strategy = "simple-shuffle";
      enable_pre_call_checks = false;
      retry_policy = {
        TimeoutErrorAllowedFails = 1;
      };
    };
  };
}
