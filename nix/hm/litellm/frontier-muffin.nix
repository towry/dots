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
      max_tokens = modelTokenMax "claude-sonnet-4.5";
      cache_control_injection_points = [
        {
          location = "message";
          role = "user";
        }
      ];
    };
  }
  {
    model_name = "frontier-muffin";
    litellm_params = {
      model = "github_copilot/gpt-5";
      extra_headers = copilotHeaders;
      max_tokens = modelTokenMax "gpt-5";
      max_output_tokens = modelTokenMax "gpt-5";
    };
  }
  {
    model_name = "frontier-muffin";
    litellm_params = {
      model = "openrouter/anthropic/claude-3.7-sonnet:thinking";
      api_key = "os.environ/OPENROUTER_API_KEY";
      cache_control_injection_points = [
        {
          location = "message";
          role = "user";
        }
      ];
      max_tokens = 64000;
      rpm = 1;
    };
  }
]
