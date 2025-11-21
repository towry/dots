{
  pkgs,
  copilotHeaders,
  modelTokenMax,
  ...
}:

[
  {
    model_name = "frontier-muffin";
    litellm_params = {
      model = "github_copilot/claude-sonnet-4.5";
      extra_headers = copilotHeaders;
      max_tokens = modelTokenMax "github_copilot/claude-sonnet-4.5";
      cache_control_injection_points = [
        {
          location = "message";
          role = "user";
        }
      ];
      rpm = 3;
    };
    model_info = {
      max_input_tokens = 128000;
      max_output_tokens = 16000;
    };
  }
  {
    model_name = "frontier-muffin";
    litellm_params = {
      model = "github_copilot/gpt-5";
      extra_headers = copilotHeaders;
      max_tokens = modelTokenMax "github_copilot/gpt-5";
      rpm = 1;
    };
    model_info = {
      max_input_tokens = 128000;
      max_output_tokens = 128000;
    };
  }
  {
    model_name = "frontier-muffin";
    litellm_params = {
      model = "openai/claude-sonnet-4-5";
      api_base = "https://opencode.ai/zen/v1";
      api_key = pkgs.nix-priv.keys.opencode.apiKey;
      max_tokens = 64000;
      rpm = 1;
    };
    model_info = {
      max_input_tokens = 1000000;
      max_output_tokens = 64000;
    };
  }
  # gpt-5.1-codex
  {
    model_name = "frontier-muffin";
    litellm_params = {
      model = "openai/gpt-5.1-codex";
      api_base = "https://opencode.ai/zen/v1";
      api_key = pkgs.nix-priv.keys.opencode.apiKey;
      max_tokens = 128000;
      rpm = 2;
    };
    model_info = {
      max_input_tokens = 400000;
      max_output_tokens = 128000;
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
  {
    model_name = "frontier-muffin";
    litellm_params = {
      model = "openai/gemini-3-pro";
      api_base = "https://opencode.ai/zen/v1";
      api_key = pkgs.nix-priv.keys.opencode.apiKey;
      max_tokens = 64000;
      rpm = 1;
    };
    model_info = {
      max_input_tokens = 1000000;
      max_output_tokens = 64000;
    };
  }
]
