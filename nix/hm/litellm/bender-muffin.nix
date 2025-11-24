{
  pkgs,
  copilotHeaders,
  getMaxInputTokens,
  getMaxOutputTokens,
  getMaxTokens,
  ...
}:

[
  # {
  #   model_name = "bender-muffin";
  #   litellm_params = {
  #     model = "github_copilot/claude-haiku-4.5";
  #     extra_headers = copilotHeaders;
  #     max_tokens = 16000;
  #     rpm = 4;
  #   };
  #   model_info = {
  #     max_input_tokens = 128000;
  #     max_output_tokens = 16000;
  #   };
  # }
  # 64,000

  # {
  #   model_name = "bender-muffin";
  #   litellm_params = {
  #     model = "github_copilot/gpt-5-mini";
  #     extra_headers = copilotHeaders;
  #     max_tokens = modelTokenMax "gpt-5-mini";
  #     rpm = 1;
  #   };
  # }
  # {
  #   model_name = "bender-muffin";
  #   litellm_params = {
  #     model = "openai/minimax-m2";
  #     api_key = pkgs.nix-priv.keys.minimax.codingPlanApiKey;
  #     api_base = "https://api.minimaxi.com/v1";
  #     max_tokens = 128000;
  #     rpm = 10;
  #   };
  # }
  # {
  #   model_name = "bender-muffin";
  #   litellm_params = {
  #     model = "dashscope/qwen3-coder-plus";
  #     api_key = pkgs.nix-priv.keys.alimodel.apiKey;
  #     api_base = "https://dashscope.aliyuncs.com/compatible-mode/v1";
  #     max_tokens = 65536;
  #     rpm = 1;
  #   };
  # }
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "openrouter/x-ai/grok-4.1-fast";
      api_key = "os.environ/OPENROUTER_API_KEY";
      rpm = 5;
    };
    model_info = {
      max_input_tokens = 2000000;
      max_output_tokens = 30000;
    };
  }
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "openai/glm-4.6";
      api_base = "https://open.bigmodel.cn/api/coding/paas/v4";
      api_key = pkgs.nix-priv.keys.zai.apiKey;
      max_tokens = 131072;
      rpm = 2;
    };
    model_info = {
      max_input_tokens = 204800;
      max_output_tokens = 131072;
    };
  }
  # {
  #   model_name = "bender-muffin";
  #   litellm_params = {
  #     model = "openai/qwen3-coder";
  #     api_base = "https://opencode.ai/zen/v1";
  #     api_key = pkgs.nix-priv.keys.opencode.apiKey;
  #     max_tokens = 65536;
  #     rpm = 2;
  #   };
  #   model_info = {
  #     max_input_tokens = 262144;
  #     max_output_tokens = 65536;
  #   };
  # }
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "openai/big-pickle";
      api_base = "https://opencode.ai/zen/v1";
      api_key = pkgs.nix-priv.keys.opencode.apiKey;
      max_tokens = 128000;
      rpm = 10;
    };
    model_info = {
      max_input_tokens = 200000;
      max_output_tokens = 128000;
    };
  }
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "openrouter/anthropic/claude-haiku-4.5";
      api_key = "os.environ/OPENROUTER_API_KEY";
      max_tokens = 64000;
      rpm = 4;
    };
    model_info = {
      max_input_tokens = 200000;
      max_output_tokens = 64000;
    };
  }
  # {
  #   model_name = "bender-muffin";
  #   litellm_params = {
  #     model = "openai/claude-sonnet-4-5";
  #     api_base = "https://opencode.ai/zen/v1";
  #     api_key = pkgs.nix-priv.keys.opencode.apiKey;
  #     max_tokens = 64000;
  #     rpm = 1;
  #   };
  #   model_info = {
  #     max_input_tokens = 1000000;
  #     max_output_tokens = 64000;
  #   };
  # }
]
