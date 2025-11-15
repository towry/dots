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
      max_output_tokens = modelTokenMax "claude-sonnet-4.5";
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
]
