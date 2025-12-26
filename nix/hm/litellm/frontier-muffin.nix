{
  pkgs,
  ...
}:

let
  providers = import ./transportProviders.nix { inherit pkgs; };
  modelName = "frontier-muffin";
in
[
  (providers.packyGemini.model {
    model_name = "packy/gemini-3-pro";
    litellm_params = {
      model = "anthropic/gemini-3-pro-preview";
      rpm = 5;
    };
  })
  (providers.packyOpenai.model {
    model_name = modelName;
    litellm_params = {
      model = "anthropic/gpt-5.2-high";
    };
  })
  (providers.packyCc.model {
    model_name = modelName;
    litellm_params = {
      model = "anthropic/claude-sonnet-4-5-20250929";
      rpm = 1;
    };
  })
  (providers.packyCc.model {
    model_name = modelName;
    litellm_params = {
      model = "anthropic/claude-opus-4-5-20251101";
      rpm = 2;
    };
  })
]
