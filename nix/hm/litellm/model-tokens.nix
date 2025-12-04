# Model token limits (input/output) from models.dev API
# Data source: https://models.dev/api.json (downloaded locally for reference)
# Different providers have different limits for the same model names!
#
# Usage: getModelTokens "github_copilot/gpt-5" -> { input = 128000; output = 128000; }
#        getModelTokens "openai/gpt-5.1-codex" -> { input = 400000; output = 128000; }
#        getMaxInputTokens "gpt-5" -> looks up defaults first
#        getMaxOutputTokens "github_copilot/gpt-5" -> 128000
{ lib }:

let
  # Provider-specific token configurations
  # Structure: provider.model-name = { input = context_window; output = max_output_tokens; }
  providerTokens = {
    # GitHub Copilot provider (via models.dev)
    github_copilot = {
      "gpt-5" = {
        input = 128000;
        output = 128000;
      };
      "gpt-5-mini" = {
        input = 128000;
        output = 128000;
      };
      "gpt-5.1" = {
        input = 128000;
        output = 128000;
      };
      "gpt-5.1-codex" = {
        input = 128000;
        output = 128000;
      };
      "gpt-5.1-codex-mini" = {
        input = 128000;
        output = 128000;
      };
      "gpt-4.1" = {
        input = 32768;
        output = 32768;
      };
      "gpt-4o" = {
        input = 128000;
        output = 16384;
      };
      "claude-haiku-4.5" = {
        input = 128000;
        output = 16000;
      };
      "claude-sonnet-4" = {
        input = 128000;
        output = 16000;
      };
      "claude-sonnet-4.5" = {
        input = 128000;
        output = 16000;
      };
      "claude-opus-41" = {
        input = 80000;
        output = 16000;
      };
      "gemini-2.5-pro" = {
        input = 1000000;
        output = 8192;
      };
      "gemini-2.5-flash" = {
        input = 1000000;
        output = 8192;
      };
      "gemini-3-pro-preview" = {
        input = 1000000;
        output = 8192;
      };
      "grok-code-fast-1" = {
        input = 128000;
        output = 64000;
      };
      "oswe-vscode-prime" = {
        input = 128000;
        output = 64000;
      };
    };

    # OpenAI provider (via models.dev)
    openai = {
      "gpt-5" = {
        input = 128000;
        output = 128000;
      };
      "gpt-5-mini" = {
        input = 128000;
        output = 128000;
      };
      "gpt-5.1" = {
        input = 400000;
        output = 128000;
      };
      "gpt-5.1-codex" = {
        input = 400000;
        output = 128000;
      };
      "gpt-4.1" = {
        input = 1047576;
        output = 32768;
      };
      "gpt-4o" = {
        input = 128000;
        output = 16384;
      };
    };

    # Anthropic provider (via models.dev)
    anthropic = {
      "claude-haiku-4.5" = {
        input = 200000;
        output = 64000;
      };
      "claude-haiku-4-5" = {
        input = 200000;
        output = 64000;
      }; # alternate naming
      "claude-sonnet-4" = {
        input = 200000;
        output = 64000;
      };
      "claude-sonnet-4.5" = {
        input = 200000;
        output = 64000;
      };
      "claude-sonnet-4-5" = {
        input = 200000;
        output = 8192;
      }; # alternate naming
      "claude-opus-41" = {
        input = 200000;
        output = 32000;
      };
      "claude-opus-4-1" = {
        input = 200000;
        output = 32000;
      }; # alternate naming
    };

    # Google provider (via models.dev)
    google = {
      "gemini-2.5-pro" = {
        input = 1048576;
        output = 65536;
      };
      "gemini-2.5-flash" = {
        input = 1048576;
        output = 65536;
      };
      "gemini-3-pro-preview" = {
        input = 1000000;
        output = 65000;
      };
    };

    # xAI provider
    xai = {
      "grok-code-fast-1" = {
        input = 32768;
        output = 10000;
      };
    };

    # DeepSeek provider
    deepseek = {
      "deepseek-chat" = {
        input = 64000;
        output = 32000;
      };
      "deepseek-reasoner" = {
        input = 128000;
        output = 32000;
      };
    };

    # Zhipu AI / ZAI Coding Plan provider
    zhipuai = {
      "glm-4.6" = {
        input = 204800;
        output = 131072;
      };
      "glm-4.5-air" = {
        input = 98304;
        output = 98304;
      };
    };

    # Kimi / Moonshot AI provider
    moonshot = {
      "kimi-k2-thinking" = {
        input = 262144;
        output = 262144;
      };
    };

    # OpenCode provider (uses same limits as base providers)
    opencodeai = {
      "gpt-5" = {
        input = 400000;
        output = 128000;
      };
      "gpt-5.1" = {
        input = 400000;
        output = 128000;
      };
      "gpt-5.1-codex" = {
        input = 400000;
        output = 128000;
      };
      "claude-haiku-4-5" = {
        input = 200000;
        output = 64000;
      };
      "claude-sonnet-4-5" = {
        input = 1000000;
        output = 64000;
      };
      "gemini-3-pro" = {
        input = 1000000;
        output = 65000;
      };
      "kimi-k2" = {
        input = 262144;
        output = 262144;
      };
      "big-pickle" = {
        input = 200000;
        output = 128000;
      };
      "grok-code" = {
        input = 128000;
        output = 64000;
      };
      "qwen3-coder" = {
        input = 262144;
        output = 65536;
      };
    };

    # Alibaba Dashscope provider
    dashscope = {
      "qwen3-coder-plus" = {
        input = 262144;
        output = 65536;
      };
      "qwen3-coder-480b-a35b-instruct" = {
        input = 262144;
        output = 65536;
      };
      "qwen3-max" = {
        input = 262144;
        output = 65536;
      };
    };
  };

  # Default fallback token limits (when provider/model not found)
  defaultTokens = {
    input = 8192;
    output = 8192;
  };

  # Helper function: Extract provider and model from "provider/model" format
  # E.g., "github_copilot/gpt-5" -> { provider = "github_copilot"; model = "gpt-5"; }
  #       "gpt-5" -> { provider = null; model = "gpt-5"; }
  parseModelKey =
    m:
    let
      str = toString m;
      parts = lib.splitString "/" str;
      hasSeparator = builtins.length parts > 1;
    in
    if hasSeparator then
      {
        provider = builtins.head parts;
        model = lib.concatStringsSep "/" (lib.tail parts);
      }
    else
      {
        provider = null;
        model = str;
      };

  # Get token limits for a model with provider-aware lookup
  # Returns { input = <tokens>; output = <tokens>; } or default fallback
  #
  # Lookup order:
  # 1. provider/model (e.g., "github_copilot/gpt-5")
  # 2. Try common providers if no provider specified
  # 3. Fall back to defaultTokens
  getModelTokens =
    m:
    let
      parsed = parseModelKey m;
      provider = parsed.provider;
      model = parsed.model;

      # If provider specified, look it up directly
      providerLookup =
        if provider != null && lib.hasAttr provider providerTokens then
          let
            providerModels = builtins.getAttr provider providerTokens;
          in
          if lib.hasAttr model providerModels then builtins.getAttr model providerModels else null
        else
          null;

      # If no provider or not found, try common providers in order
      # Priority: github_copilot -> openai -> anthropic -> google
      fallbackLookup =
        let
          tryProviders = [
            "github_copilot"
            "openai"
            "anthropic"
            "google"
            "zhipuai"
            "moonshot"
          ];
          findInProvider =
            p:
            if lib.hasAttr p providerTokens then
              let
                providerModels = builtins.getAttr p providerTokens;
              in
              if lib.hasAttr model providerModels then builtins.getAttr model providerModels else null
            else
              null;
          results = builtins.filter (x: x != null) (map findInProvider tryProviders);
        in
        if builtins.length results > 0 then builtins.head results else null;
    in
    if providerLookup != null then
      providerLookup
    else if fallbackLookup != null then
      fallbackLookup
    else
      defaultTokens;

  # Get max input tokens (context window)
  getMaxInputTokens = m: (getModelTokens m).input;

  # Get max output tokens
  getMaxOutputTokens = m: (getModelTokens m).output;

  # Legacy compatibility: return output tokens (backward compatible with old modelMaxTokens)
  getMaxTokens = getMaxOutputTokens;

in
{
  inherit
    providerTokens
    defaultTokens
    parseModelKey
    getModelTokens
    getMaxInputTokens
    getMaxOutputTokens
    getMaxTokens
    ;
}
