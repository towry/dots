{
  pkgs,
  getMaxInputTokens,
  getMaxOutputTokens,
  getMaxTokens,
  ...
}:

let
  providers = import ./transportProviders.nix { inherit pkgs; };

  # DeepSeek models
  deepseekModels = providers.deepseek.models [
    "deepseek-chat"
    "deepseek-reasoner"
  ];

  # Mistral models
  mistralModels =
    builtins.map
      (
        name:
        providers.mistral.model {
          model_name = "mistral/${name}";
          litellm_params = {
            model = "mistral/${name}";
            max_tokens = getMaxOutputTokens "mistral/${name}";
          };
        }
      )
      [
        "codestral-2508"
        "devstral-2512"
      ];

  # Alibaba Cloud (Dashscope) models
  aliCnModels =
    builtins.map
      (
        name:
        providers.dashscope.model {
          model_name = "dashscope/${name}";
          litellm_params = {
            model = "dashscope/${name}";
          };
          model_info = {
            max_output_tokens = getMaxOutputTokens "dashscope/${name}";
          };
        }
      )
      [
        "qwen3-coder-plus"
        "qwen3-coder-480b-a35b-instruct"
        "qwen3-max"
      ];

  # OpenRouter models
  openrouterModels = [
    (providers.openrouter.model {
      model_name = "openrouter/mistral-large-2512";
      litellm_params = {
        model = "openrouter/mistralai/mistral-large-2512";
        max_tokens = 252000;
      };
    })
    (providers.openrouter.model {
      model_name = "openrouter/devstral-2512";
      litellm_params = {
        model = "openrouter/mistralai/devstral-2512:free";
        max_tokens = 252000;
      };
    })
    (providers.openrouter.model {
      model_name = "openrouter/*";
      litellm_params = {
        model = "openrouter/*";
      };
    })
  ];

  # Google Gemini models
  googleModels =
    builtins.map
      (
        name:
        let
          maxOutputTokens = getMaxOutputTokens "google/${name}";
        in
        providers.gemini.model {
          model_name = "gemini/${name}";
          litellm_params = {
            model = "gemini/${name}";
            max_tokens = maxOutputTokens;
            max_output_tokens = maxOutputTokens;
          };
          model_info = {
            base_model = "gemini/${name}";
            max_output_tokens = maxOutputTokens;
          };
        }
      )
      [
        "gemini-2.5-pro"
        "gemini-2.5-flash"
      ];

  # GitHub Copilot model names
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

  # GitHub Copilot models
  githubModels = builtins.map (
    name:
    let
      maxOutputTokens = getMaxOutputTokens "github_copilot/${name}";
    in
    providers.githubCopilot.model {
      model_name = "copilot/${name}";
      litellm_params = {
        model = "github_copilot/${name}";
        max_tokens = maxOutputTokens;
      };
      model_info = {
        supports_vision = true;
        max_output_tokens = maxOutputTokens;
      };
    }
  ) githubModelNames;

  # Standalone GPT-5 model (copilot alias)
  copilotGpt5Model = [
    (providers.githubCopilot.model {
      model_name = "gpt-5";
      litellm_params = {
        model = "github_copilot/gpt-5";
        max_tokens = getMaxOutputTokens "github_copilot/gpt-5";
      };
      model_info = {
        max_output_tokens = getMaxOutputTokens "github_copilot/gpt-5";
      };
    })
  ];

  # Zenmux models
  zenmuxModelNames = [
    "zenmux/auto"
    "deepseek/deepseek-reasoner"
    "anthropic/claude-opus-4.5"
    "anthropic/claude-haiku-4.5"
    "anthropic/claude-sonnet-4.5"
    "anthropic/claude-3.5-haiku"
    "z-ai/glm-4.6"
    "z-ai/glm-4.6v-flash"
    "x-ai/grok-4.1-fast"
    "x-ai/grok-code-fast-1"
    "google/gemini-3-pro-preview"
    "google/gemini-3-flash-preview"
    "openai/gpt-5.1"
    "openai/gpt-5.2"
    "openai/gpt-5.1-codex"
    "openai/gpt-5.1-codex-mini"
    "moonshotai/kimi-k2-thinking"
    "minimax/minimax-m2"
    "moonshotai/kimi-k2-thinking-turbo"
  ];

  zenmuxModels = builtins.map (
    name:
    let
      maxOutputTokens = getMaxOutputTokens "zenmux/${name}";
    in
    providers.zenmuxAnthropic.model {
      model_name = "zenmux/${name}";
      litellm_params = {
        model = "anthropic/${name}";
        max_tokens = maxOutputTokens;
      };
      model_info = {
        max_output_tokens = maxOutputTokens;
      };
    }
  ) zenmuxModelNames;

  # Opencode models
  opencodeModelNames = [
    "gpt-5"
    "gpt-5.1"
    "gpt-5.2"
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
    "glm-4.7-free"
  ];

  opencodeModels = builtins.map (
    name:
    let
      maxOutputTokens = getMaxOutputTokens "opencodeai/${name}";
    in
    providers.opencode.model {
      model_name = "opencodeai/${name}";
      litellm_params = {
        model = "openai/${name}";
        max_tokens = maxOutputTokens;
      };
      model_info = {
        max_output_tokens = maxOutputTokens;
      };
    }
  ) opencodeModelNames;

  # Zhipu AI models
  zhipuaiModels =
    builtins.map
      (
        name:
        let
          maxOutputTokens = getMaxOutputTokens "zhipuai/${name}";
        in
        providers.zhipuai.model {
          model_name = "zhipuai/${name}";
          litellm_params = {
            model = "openai/${name}";
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

  # Kimi models
  kimiModels =
    builtins.map
      (
        name:
        let
          maxOutputTokens = getMaxOutputTokens "moonshot/kimi-k2-thinking";
        in
        providers.kimi.model {
          model_name = "kimi/${name}";
          litellm_params = {
            model = "openai/${name}";
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

  # Moonshot thinking models
  moonshotThinkingModels =
    let
      maxOutputTokens = getMaxOutputTokens "moonshot/kimi-k2-thinking";
    in
    [
      (providers.moonshot.model {
        model_name = "moonshot/kimi-k2";
        litellm_params = {
          model = "moonshot/kimi-k2-0905-preview";
          max_tokens = maxOutputTokens;
          max_output_tokens = maxOutputTokens;
        };
        model_info = {
          max_output_tokens = maxOutputTokens;
        };
      })
      (providers.moonshot.model {
        model_name = "moonshot/kimi-k2-thinking";
        litellm_params = {
          model = "moonshot/kimi-k2-thinking";
          max_tokens = maxOutputTokens;
          max_output_tokens = maxOutputTokens;
        };
        model_info = {
          max_output_tokens = maxOutputTokens;
        };
      })
    ];

in
deepseekModels
++ mistralModels
++ googleModels
++ githubModels
++ copilotGpt5Model
++ zhipuaiModels
++ openrouterModels
++ kimiModels
++ moonshotThinkingModels
++ opencodeModels
++ zenmuxModels
++ aliCnModels
