{
  pkgs,
  ...
}:

let
  providers = import ./transportProviders.nix { inherit pkgs; };
  modelName = "frontier-muffin";
in
[
  # gemeini 3
  (providers.packyGemini.model {
    model_name = modelName;
    litellm_params = {
      model = "anthropic/claude-opus-4-5-20251101
";
      rpm = 50;
    };
    model_info = {
      max_output_tokens = 64000;
    };
  })
  (providers.packyCc.model {
    model_name = modelName;
    litellm_params = {
      model = "anthropic/claude-sonnet-4-5-20250929";
      rpm = 2;
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
]
