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
    model_name = "free-muffin";
    litellm_params = {
      model = "openai/minimax-m2";
      api_key = pkgs.nix-priv.keys.minimax.codingPlanApiKey;
      api_base = "https://api.minimaxi.com/v1";
      max_tokens = 128000;
      rpm = 10;
      extra_body = {
        reasoning_split = true;
      };
    };
    model_info = {
      max_input_tokens = 204800;
      max_output_tokens = 128000;
    };
  }
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "github_copilot/oswe-vscode-prime";
      extra_headers = copilotHeaders;
      max_tokens = 64000;
      rpm = 4;
    };
    model_info = {
      max_input_tokens = 128000;
      max_output_tokens = 64000;
    };
  }
  # {
  #   model_name = "free-muffin";
  #   litellm_params = {
  #     model = "dashscope/qwen3-coder-plus";
  #     api_key = pkgs.nix-priv.keys.alimodel.apiKey;
  #     api_base = "https://dashscope.aliyuncs.com/compatible-mode/v1";
  #     max_tokens = 65536;
  #     rpm = 1;
  #   };
  # }
  {
    model_name = "free-muffin";
    litellm_params = {
      model = "openai/glm-4.5";
      api_base = "https://open.bigmodel.cn/api/coding/paas/v4";
      api_key = pkgs.nix-priv.keys.zai.apiKey;
      max_tokens = 131072;
      rpm = 10;
    };
  }
  {
    model_name = "free-muffin";
    litellm_params = {
      model = "openai/big-pickle";
      api_base = "https://opencode.ai/zen/v1";
      api_key = pkgs.nix-priv.keys.opencode.apiKey;
      max_tokens = 128000;
      rpm = 20;
    };
  }
]
