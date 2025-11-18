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
      model = "github_copilot/claude-sonnet-4.5";
      extra_headers = copilotHeaders;
      max_tokens = modelTokenMax "claude-sonnet-4.5";
      rpm = 1;
    };
  }
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "github_copilot/claude-haiku-4.5";
      extra_headers = copilotHeaders;
      max_tokens = modelTokenMax "claude-haiku-4.5";
    };
  }
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "dashscope/qwen3-coder-plus";
      api_key = pkgs.nix-priv.keys.alimodel.apiKey;
      api_base = "https://dashscope.aliyuncs.com/compatible-mode/v1";
      max_tokens = 65536;
      rpm = 3;
    };
  }
  {
    model_name = "free-muffin";
    litellm_params = {
      model = "openai/minimax-m2";
      api_key = pkgs.nix-priv.keys.minimax.codingPlanApiKey;
      api_base = "https://api.minimaxi.com/v1";
      max_tokens = 128000;
    };
  }
]
