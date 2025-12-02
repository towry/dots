{
  pkgs,
  copilotHeaders,
  getMaxInputTokens,
  getMaxOutputTokens,
  getMaxTokens,
  ...
}:

[
  {
    model_name = "frontier-muffin";
    litellm_params = {
      model = "github_copilot/claude-sonnet-4.5";
      extra_headers = copilotHeaders;
      max_tokens = getMaxOutputTokens "github_copilot/claude-sonnet-4.5";
      rpm = 3;
    };
    model_info = {
      max_input_tokens = getMaxInputTokens "github_copilot/claude-sonnet-4.5";
      max_output_tokens = getMaxOutputTokens "github_copilot/claude-sonnet-4.5";
    };
  }
  {
    model_name = "frontier-muffin";
    litellm_params = {
      model = "github_copilot/gpt-5.1";
      extra_headers = copilotHeaders;
      max_tokens = getMaxOutputTokens "github_copilot/gpt-5.1";
      rpm = 5;
    };
    model_info = {
      max_input_tokens = getMaxInputTokens "github_copilot/gpt-5.1";
      max_output_tokens = getMaxOutputTokens "github_copilot/gpt-5.1";
    };
  }
  # {
  #   model_name = "frontier-muffin";
  #   litellm_params = {
  #     model = "openrouter/anthropic/claude-opus-4.5";
  #     max_tokens = 32000;
  #     rpm = 1;
  #     provider = {
  #       sort = "price";
  #     };
  #     reasoning = {
  #       effort = "high";
  #     };
  #   };
  #   model_info = {
  #     max_input_tokens = 200000;
  #     max_output_tokens = 32000;
  #   };
  # }
  {
    model_name = "frontier-muffin";
    litellm_params = {
      model = "openai/gpt-5";
      api_base = "https://opencode.ai/zen/v1";
      api_key = pkgs.nix-priv.keys.opencode.apiKey;
      max_tokens = 64000;
      rpm = 1;
    };
    model_info = {
      max_input_tokens = 272000;
      max_output_tokens = 128000;
    };
  }

  {
    model_name = "frontier-muffin";
    litellm_params = {
      model = "openai/kimi-k2-thinking";
      api_base = "https://opencode.ai/zen/v1";
      api_key = pkgs.nix-priv.keys.opencode.apiKey;
      max_tokens = 262144;
      rpm = 6;
    };
    model_info = {
      max_input_tokens = 262144;
      max_output_tokens = 262144;
    };
  }
]
