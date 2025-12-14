{
  pkgs,
  copilotHeaders,
  getMaxInputTokens,
  getMaxOutputTokens,
  getMaxTokens,
  ...
}:

[
  # {
  #   model_name = "frontier-muffin";
  #   litellm_params = {
  #     model = "github_copilot/claude-sonnet-4.5";
  #     extra_headers = copilotHeaders;
  #     max_tokens = getMaxOutputTokens "github_copilot/claude-sonnet-4.5";
  #     rpm = 10;
  #   };
  #   model_info = {
  #     max_output_tokens = getMaxOutputTokens "github_copilot/claude-sonnet-4.5";
  #   };
  # }
  {
    model_name = "frontier-muffin";
    litellm_params = {
      model = "anthropic/claude-sonnet-4-5-20250929";
      use_in_pass_through = true;
      api_base = "https://www.packyapi.com";
      api_key = pkgs.nix-priv.keys.customProviders.packyCcKey;
      max_tokens = 64000;
    };
    model_info = {
      max_output_tokens = 64000;
    };
  }
  {
    model_name = "frontier-muffin";
    litellm_params = {
      model = "anthropic/claude-opus-4-5-20251101";
      use_in_pass_through = true;
      api_base = "https://www.packyapi.com";
      api_key = pkgs.nix-priv.keys.customProviders.packyCcKey;
      max_tokens = 64000;
      rpm = 2;
    };
    model_info = {
      max_output_tokens = 64000;
    };
  }
  # {
  #   model_name = "frontier-muffin";
  #   litellm_params = {
  #     model = "anthropic/gpt-5-codex-high";
  #     use_in_pass_through = false;
  #     api_base = "https://www.packyapi.com";
  #     api_key = pkgs.nix-priv.keys.customProviders.packyOpenaiKey;
  #     max_tokens = 128000;
  #     rpm = 10;
  #   };
  #   model_info = {
  #     max_output_tokens = 128000;
  #   };
  # }
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
]
