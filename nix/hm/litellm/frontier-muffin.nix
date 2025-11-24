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
      model = "github_copilot/gpt-5";
      extra_headers = copilotHeaders;
      max_tokens = getMaxOutputTokens "github_copilot/gpt-5";
      rpm = 3;
    };
    model_info = {
      max_input_tokens = getMaxInputTokens "github_copilot/gpt-5";
      max_output_tokens = getMaxOutputTokens "github_copilot/gpt-5";
    };
  }
  {
    model_name = "frontier-muffin";
    litellm_params = {
      model = "openai/claude-sonnet-4-5";
      api_base = "https://opencode.ai/zen/v1";
      api_key = pkgs.nix-priv.keys.opencode.apiKey;
      max_tokens = 64000;
      rpm = 2;
    };
    model_info = {
      max_input_tokens = 1000000;
      max_output_tokens = 64000;
    };
  }
  # {
  #   model_name = "frontier-muffin";
  #   litellm_params = {
  #     model = "github_copilot/gemini-3-pro-preview";
  #     extra_headers = copilotHeaders;
  #     max_tokens = modelTokenMax "github_copilot/gemini-3-pro-preview";
  #   };
  # }

  ## keep get auth issue
  # {
  #   model_name = "frontier-muffin";
  #   litellm_params = {
  #     model = "openai/gemini-3-pro";
  #     api_base = "https://opencode.ai/zen/v1";
  #     api_key = pkgs.nix-priv.keys.opencode.apiKey;
  #     max_tokens = 64000;
  #     rpm = 2;
  #   };
  #   model_info = {
  #     max_input_tokens = 1000000;
  #     max_output_tokens = 64000;
  #   };
  # }
]
