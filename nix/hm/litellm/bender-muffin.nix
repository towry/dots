# bender-muffin: Load-balanced model group
# Randomly routes between copilot/claude-haiku-4.5, openrouter grok-4-fast, qwen3-coder, minimax-m2
{
  pkgs,
  copilotHeaders,
  modelTokenMax,
  ...
}:

[
  # Model 1: GitHub Copilot Claude Haiku
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "github_copilot/claude-haiku-4.5";
      extra_headers = copilotHeaders;
      max_tokens = modelTokenMax "claude-haiku-4.5";
      max_output_tokens = modelTokenMax "claude-haiku-4.5";
    };
  }
  # Model 2: OpenRouter Grok 4 Fast
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "openrouter/x-ai/grok-4-fast";
      api_key = "os.environ/OPENROUTER_API_KEY";
      max_tokens = 32768;
      max_output_tokens = 32768;
    };
  }
  # Model 3: OpenRouter Qwen3 Coder
  {
    model_name = "bender-muffin";
    litellm_params = {
      model = "openrouter/qwen/qwen3-coder";
      api_key = "os.environ/OPENROUTER_API_KEY";
      max_tokens = 32768;
      max_output_tokens = 32768;
    };
  }
  # Model 4: OpenRouter Minimax M2
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
