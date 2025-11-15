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
      rpm = 1000;
    };
  }
  # {
  #   model_name = "bender-muffin";
  #   litellm_params = {
  #     model = "github_copilot/oswe-vscode-prime";
  #     extra_headers = copilotHeaders;
  #     max_tokens = modelTokenMax "grok-code-fast-1";
  #   };
  # }
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "dashscope/qwen3-coder-plus";
      api_key = pkgs.nix-priv.keys.alimodel.apiKey;
      api_base = "https://dashscope.aliyuncs.com/compatible-mode/v1";
      max_tokens = 65536;
      rpm = 1000;
    };
  }
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "openai/glm-4.6";
      api_base = "https://open.bigmodel.cn/api/coding/paas/v4";
      api_key = pkgs.nix-priv.keys.zai.apiKey;
      max_tokens = 128000;
      rpm = 1000;
    };
  }
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "openrouter/openai/gpt-5.1-codex-mini";
      api_key = "os.environ/OPENROUTER_API_KEY";
      max_tokens = 100000;
      rpm = 50;
    };
  }
  # {
  #   model_name = "bender-muffin";
  #   litellm_params = {
  #     model = "openrouter/minimax/minimax-m2";
  #     api_key = "os.environ/OPENROUTER_API_KEY";
  #     max_tokens = 32768;
  #   };
  # }
  ## have issues, kimi
  # {
  #   model_name = "bender-muffin";
  #   litellm_params = {
  #     model = "moonshot/kimi-k2-0905-preview";
  #     api_base = "https://api.moonshot.cn/v1";
  #     api_key = "${pkgs.nix-priv.keys.moonshot.apiKey}";
  #     max_tokens = 262144;
  #     max_output_tokens = 262144;
  #   };
  # }
]
