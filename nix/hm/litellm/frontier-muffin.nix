{
  pkgs,
  ...
}:

let
  providers = import ./transportProviders.nix { inherit pkgs; };
  modelName = "frontier-muffin";
in
[
  (providers.packyCc.model {
    model_name = modelName;
    litellm_params = {
      model = "anthropic/claude-sonnet-4-5-20250929";
      rpm = 3;
    };
    model_info = {
      max_output_tokens = 64000;
    };
  })
  (providers.packyCc.model {
    model_name = modelName;
    litellm_params = {
      model = "anthropic/claude-opus-4-5-20251101";
      rpm = 1;
    };
    model_info = {
      max_output_tokens = 64000;
    };
  })
  # gemeini 3
  (providers.packyGemini.model {
    model_name = modelName;
    litellm_params = {
      model = "gemini/gemini-3-pro-preview";
      max_tokens = 64000;
    };
    model_info = {
      max_output_tokens = 64000;
    };
  })
]
