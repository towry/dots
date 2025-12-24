{
  pkgs,
  ...
}:

let
  providers = import ./transportProviders.nix { inherit pkgs; };
  modelName = "free-muffin";
in
[
  (providers.minimax.model {
    model_name = modelName;
    litellm_params = {
      model = "openai/minimax-m2";
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
  })
  (providers.githubCopilot.model {
    model_name = modelName;
    litellm_params = {
      model = "github_copilot/oswe-vscode-prime";
      max_tokens = 64000;
      rpm = 4;
    };
    model_info = {
      max_input_tokens = 128000;
      max_output_tokens = 64000;
    };
  })
  (providers.zhipuai.model {
    model_name = modelName;
    litellm_params = {
      model = "openai/glm-4.5";
      max_tokens = 131072;
      rpm = 10;
    };
  })
  (providers.opencode.model {
    model_name = modelName;
    litellm_params = {
      model = "openai/big-pickle";
      max_tokens = 128000;
      rpm = 20;
    };
  })
]
