{
  pkgs,
  copilotHeaders,
  modelTokenMax,
  ...
}:

[
  {
    model_name = "free-muffin";
    litellm_params = {
      model = "openai/minimax-m2";
      api_key = pkgs.nix-priv.keys.minimax.codingPlanApiKey;
      api_base = "https://api.minimaxi.com/v1";
      max_tokens = 128000;
      rpm = 20;
    };
  }
  {
    model_name = "free-muffin";
    litellm_params = {
      model = "github_copilot/oswe-vscode-prime";
      extra_headers = copilotHeaders;
      max_tokens = modelTokenMax "oswe-vscode-prime";
      rpm = 2;
    };
  }
  {
    model_name = "free-muffin";
    litellm_params = {
      model = "dashscope/qwen3-coder-plus";
      api_key = pkgs.nix-priv.keys.alimodel.apiKey;
      api_base = "https://dashscope.aliyuncs.com/compatible-mode/v1";
      max_tokens = 65536;
      rpm = 20;
    };
  }
]
