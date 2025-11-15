{
  pkgs,
  copilotHeaders,
  modelTokenMax,
  ...
}:

[
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "github_copilot/claude-haiku-4.5";
      extra_headers = copilotHeaders;
      max_tokens = modelTokenMax "claude-haiku-4.5";
      max_output_tokens = modelTokenMax "claude-haiku-4.5";
    };
  }
  # {
  #   model_name = "bender-muffin";
  #   litellm_params = {
  #     model = "github_copilot/oswe-vscode-prime";
  #     extra_headers = copilotHeaders;
  #     max_tokens = modelTokenMax "grok-code-fast-1";
  #     max_output_tokens = modelTokenMax "grok-code-fast-1";
  #   };
  # }
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "openrouter/qwen/qwen3-coder";
      api_key = "os.environ/OPENROUTER_API_KEY";
      max_tokens = 32768;
      max_output_tokens = 32768;
    };
  }
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "openrouter/minimax/minimax-m2";
      api_key = "os.environ/OPENROUTER_API_KEY";
      max_tokens = 32768;
      max_output_tokens = 32768;
    };
  }
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "moonshot/kimi-k2-0905-preview";
      api_base = "https://api.moonshot.cn/v1";
      api_key = "${pkgs.nix-priv.keys.moonshot.apiKey}";
      max_tokens = 262144;
      max_output_tokens = 262144;
    };
  }
]
