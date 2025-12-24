{
  pkgs,
  ...
}:

let
  providers = import ./transportProviders.nix { inherit pkgs; };
  modelName = "bender-muffin";
in
[
  # (providers.minimaxClaude.model {
  #   model_name = modelName;
  #   litellm_params = {
  #     model = "anthropic/MiniMax-M2.1";
  #     max_tokens = 64000;
  #   };
  # })
  (providers.zenmuxAnthropic.model {
    model_name = modelName;
    litellm_params = {
      model = "anthropic/anthropic/claude-haiku-4.5";
      max_tokens = 64000;
      rpm = 1;
    };
  })
  (providers.zenmuxAnthropic.model {
    model_name = modelName;
    litellm_params = {
      model = "anthropic/google/gemini-3-flash-preview";
      max_tokens = 64000;
      rpm = 2;
    };
  })
  (providers.opencode.model {
    model_name = modelName;
    litellm_params = {
      model = "openai/glm-4.7-free";
      max_tokens = 65536;
    };
  })
]
