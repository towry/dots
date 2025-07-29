{
  pkgs,
  lib,
  ...
}:
{
  # Note: gptme tools installation is handled by scripts/install-gptme.sh
  # Run manually: ./scripts/install-gptme.sh

  xdg.configFile = {
    "gptme/config.toml" = {
      source = pkgs.replaceVars ../../conf/llm/gptme/config.toml {
        OPENROUTER_API_KEY = pkgs.nix-priv.keys.openrouter.apiKey;
        PERPLEXITY_API_KEY = pkgs.nix-priv.keys.perplexity.apiKey;
      };
    };
  };
}
