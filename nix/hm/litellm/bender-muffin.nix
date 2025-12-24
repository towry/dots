{
  pkgs,
  ...
}:

let
  providers = import ./transportProviders.nix { inherit pkgs; };
  modelName = "bender-muffin";
in
[
  (providers.zenmuxAnthropic.model {
    model_name = modelName;
    litellm_params = {
      model = "anthropic/anthropic/claude-haiku-4.5";
      use_in_pass_through = true;
      max_tokens = 64000;
      rpm = 1;
    };
  })
  (providers.zenmuxAnthropic.model {
    model_name = modelName;
    litellm_params = {
      model = "anthropic/google/gemini-3-flash-preview";
      max_tokens = 64000;
      use_in_pass_through = true;
      rpm = 1;
    };
  })
  (providers.opencode.model {
    model_name = modelName;
    litellm_params = {
      model = "openai/glm-4.7-free";
      max_tokens = 65536;
      rpm = 8;
    };
  })
  (providers.packyCc.model {
    model_name = modelName;
    litellm_params = {
      model = "anthropic/claude-haiku-4-5-20251001";
      use_in_pass_through = true;
      max_tokens = 64000;
    };
  })
]
