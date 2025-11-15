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
      model = "github_copilot/grok-code-fast-1";
      extra_headers = copilotHeaders;
      max_tokens = modelTokenMax "grok-code-fast-1";
    };
  }
  {
    model_name = "free-muffin";
    litellm_params = {
      model = "github_copilot/oswe-vscode-prime";
      extra_headers = copilotHeaders;
      max_tokens = modelTokenMax "oswe-vscode-prime";
    };
  }
  {
    model_name = "free-muffin";
    litellm_params = {
      model = "dashscope/qwen3-coder-plus";
      api_key = pkgs.nix-priv.keys.alimodel.apiKey;
      api_base = "https://dashscope.aliyuncs.com/compatible-mode/v1";
      max_tokens = 65536;
    };
  }
  {
    model_name = "free-muffin";
    litellm_params = {
      model = "openai/glm-4.6";
      api_base = "https://open.bigmodel.cn/api/coding/paas/v4";
      api_key = pkgs.nix-priv.keys.zai.apiKey;
      max_tokens = 128000;
    };
  }
  # {
  #   model_name = "free-muffin";
  #   litellm_params = {
  #     model = "openrouter/minimax/minimax-m2";
  #     api_key = "os.environ/OPENROUTER_API_KEY";
  #     max_tokens = 32768;
  #   };
  # }
]
