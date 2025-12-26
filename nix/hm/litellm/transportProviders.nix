{ pkgs, ... }:

let
  lib = pkgs.lib;

  # GitHub Copilot headers
  copilotHeaders = {
    Editor-Version = "vscode/${pkgs.vscode.version}";
    editor-plugin-version = "copilot/${pkgs.vscode-extensions.github.copilot.version}";
    Copilot-Integration-Id = "vscode-chat";
    Copilot-Vision-Request = "true";
    user-agent = "GithubCopilot/${pkgs.vscode-extensions.github.copilot.version}";
  };

  # Claude CLI-ish headers
  # TODO: Keep these in sync with the Claude CLI version you use.
  claudeHeaders = {
    accept = "application/json";
    user-agent = "claude-cli/2.0.76 (external, cli)";
    x-app = "cli";
    anthropic-version = "2023-06-01";
    anthropic-beta = "claude-code-20250219,interleaved-thinking-2025-05-14";
    anthropic-dangerous-direct-browser-access = "true";
    accept-language = "*";
    sec-fetch-mode = "cors";
    accept-encoding = "gzip, deflate";
    x-stainless-lang = "js";
    x-stainless-runtime = "node";
    x-stainless-runtime-version = "v22.21.1";
    x-stainless-os = "MacOS";
    x-stainless-arch = "arm64";
    x-stainless-package-version = "0.70.0";
    x-stainless-timeout = "600";
    x-stainless-retry-count = "0";
  };

  # Codex CLI-ish headers
  #
  # NOTE: Codex CLI (openai/codex) sets an `originator` header (default: "codex_cli_rs")
  # TODO: If you want exact parity, capture real Codex CLI headers and update these values.
  codexHeaders = {
    # Codex CLI uses SSE for streaming responses.
    accept = "text/event-stream";
    originator = "codex_cli_rs";
    user-agent = "codex_cli_rs/0.77.0 (Mac OS 26.1.0; arm64) ghostty/1.3.0-main_2a9a57daf";

    # Optional Codex feature flags (sent by Codex CLI when enabled).
    # NOTE: Per-request headers like `conversation_id` / `session_id` are intentionally not set here.
    x-codex-beta-features = "unified_exec";
  };

  # Gemini CLI-ish headers
  #
  # NOTE: gemini-cli (google-gemini/gemini-cli) sets a `User-Agent` like:
  #   GeminiCLI/<version>/<model> (<platform>; <architecture>)
  # and may include `x-gemini-api-privileged-user-id` when usage stats are enabled.
  # TODO: If you want exact parity, capture real gemini-cli headers and update these values.
  geminiHeaders = {
    accept = "application/json";
    user-agent = "GeminiCLI/0.0.0/gemini (darwin; arm64)";
  };

  # mkProvider - creates a provider with two helpers:
  #   - models: simple list of model names -> full entries
  #   - model: full control with exact litellm shape
  #
  # Example:
  #   deepseek = mkProvider {
  #     prefix = "deepseek";
  #     litellm_params = { api_key = "..."; };
  #   };
  #   deepseek.models [ "deepseek-chat" "deepseek-reasoner" ]
  #   deepseek.model { model_name = "..."; litellm_params = { model = "..."; rpm = 5; }; }
  mkProvider =
    {
      prefix ? null,
      litellm_params ? { },
      model_info ? { },
    }:
    let
      defaultLitellmParams = litellm_params;
      defaultModelInfo = model_info;
    in
    {
      # Simple: list of model names -> generates full entries with prefix
      models =
        modelNames:
        builtins.map (
          name:
          let
            fullName = if prefix != null then "${prefix}/${name}" else name;
          in
          {
            model_name = fullName;
            litellm_params = defaultLitellmParams // {
              model = fullName;
            };
          }
          // lib.optionalAttrs (defaultModelInfo != { }) { model_info = defaultModelInfo; }
        ) modelNames;

      # Full control: exact litellm shape, merged with provider defaults
      model =
        {
          model_name,
          litellm_params ? { },
          model_info ? { },
        }:
        {
          inherit model_name;
          litellm_params = defaultLitellmParams // litellm_params;
        }
        // lib.optionalAttrs (defaultModelInfo != { } || model_info != { }) {
          model_info = defaultModelInfo // model_info;
        };
    };

in
{
  inherit mkProvider;

  # Packy Anthropic provider
  packyCc = mkProvider {
    litellm_params = {
      api_base = "https://www.packyapi.com";
      api_key = pkgs.nix-priv.keys.customProviders.packyCcKey;
      extra_headers = claudeHeaders;
    };
  };

  # Packy OpenAI provider
  packyOpenai = mkProvider {
    litellm_params = {
      api_base = "https://www.packyapi.com";
      api_key = pkgs.nix-priv.keys.customProviders.packyOpenaiKey;
      extra_headers = codexHeaders;
    };
  };

  # not gemini
  packyGemini = mkProvider {
    litellm_params = {
      api_base = "https://www.packyapi.com";
      api_key = pkgs.nix-priv.keys.customProviders.packyGemini;
      extra_headers = geminiHeaders;
    };
  };

  # Zenmux Anthropic provider
  zenmuxAnthropic = mkProvider {
    litellm_params = {
      api_base = "https://zenmux.ai/api/anthropic";
      api_key = pkgs.nix-priv.keys.zenmux.apiKey;
    };
  };

  # Opencode provider
  opencode = mkProvider {
    litellm_params = {
      api_base = "https://opencode.ai/zen/v1";
      api_key = pkgs.nix-priv.keys.opencode.apiKey;
    };
  };

  # DeepSeek provider
  deepseek = mkProvider {
    prefix = "deepseek";
    litellm_params = {
      api_key = "os.environ/DEEPSEEK_API_KEY";
      stream = true;
    };
  };

  # Mistral provider
  mistral = mkProvider {
    prefix = "mistral";
    litellm_params = {
      api_key = pkgs.nix-priv.keys.mistra.apiKey;
    };
  };

  # Alibaba Cloud (Dashscope) provider
  dashscope = mkProvider {
    prefix = "dashscope";
    litellm_params = {
      api_key = pkgs.nix-priv.keys.alimodel.apiKey;
      api_base = "https://dashscope.aliyuncs.com/compatible-mode/v1";
    };
  };

  # OpenRouter provider
  openrouter = mkProvider {
    litellm_params = {
      api_key = pkgs.nix-priv.keys.openrouter.apiKey;
    };
  };

  # Google Gemini provider
  gemini = mkProvider {
    litellm_params = {
      api_key = "os.environ/GEMINI_API_KEY";
    };
  };

  # GitHub Copilot provider
  githubCopilot = mkProvider {
    litellm_params = {
      extra_headers = copilotHeaders;
    };
  };

  # Zhipu AI provider
  zhipuai = mkProvider {
    litellm_params = {
      api_base = "https://open.bigmodel.cn/api/coding/paas/v4";
      api_key = pkgs.nix-priv.keys.zai.apiKey;
    };
  };

  # Kimi provider
  kimi = mkProvider {
    litellm_params = {
      api_base = "https://api.kimi.com/coding/v1";
      api_key = pkgs.nix-priv.keys.kimi.apiKey;
      reasoning_effort = "medium";
    };
  };

  # Moonshot provider
  moonshot = mkProvider {
    litellm_params = {
      api_base = "https://api.moonshot.cn/v1";
      api_key = pkgs.nix-priv.keys.moonshot.apiKey;
    };
  };

  # MiniMax provider (OpenAI compatible)
  minimax = mkProvider {
    litellm_params = {
      api_base = "https://api.minimaxi.com/v1";
      api_key = pkgs.nix-priv.keys.minimax.codingPlanApiKey;
    };
  };

  # MiniMax Claude provider (Anthropic compatible)
  minimaxClaude = mkProvider {
    litellm_params = {
      api_base = "https://api.minimaxi.com/anthropic";
      api_key = pkgs.nix-priv.keys.minimax.codingPlanApiKey;
    };
  };
}
