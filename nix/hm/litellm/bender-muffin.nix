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
      rpm = 2;
    };
  }
  # 64,000

  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "github_copilot/oswe-vscode-prime";
      extra_headers = copilotHeaders;
      max_tokens = modelTokenMax "oswe-vscode-prime";
      rpm = 2;
    };
  }
  # {
  #   model_name = "bender-muffin";
  #   litellm_params = {
  #     model = "openai/minimax-m2";
  #     api_key = pkgs.nix-priv.keys.minimax.codingPlanApiKey;
  #     api_base = "https://api.minimaxi.com/v1";
  #     max_tokens = 128000;
  #     rpm = 5;
  #   };
  # }
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "dashscope/qwen3-coder-plus";
      api_key = pkgs.nix-priv.keys.alimodel.apiKey;
      api_base = "https://dashscope.aliyuncs.com/compatible-mode/v1";
      max_tokens = 65536;
      rpm = 1;
    };
  }
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "openai/glm-4.6";
      api_base = "https://open.bigmodel.cn/api/coding/paas/v4";
      api_key = pkgs.nix-priv.keys.zai.apiKey;
      max_tokens = 131072;
      rpm = 4;
    };
  }
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "openai/big-pickle";
      api_base = "https://opencode.ai/zen/v1";
      api_key = pkgs.nix-priv.keys.opencode.apiKey;
      max_tokens = 128000;
      rpm = 20;
    };
  }
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "openai/claude-haiku-4-5";
      api_base = "https://opencode.ai/zen/v1";
      api_key = pkgs.nix-priv.keys.opencode.apiKey;
      max_tokens = 64000;
      rpm = 1;
    };
  }
]
