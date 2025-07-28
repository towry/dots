{
  pkgs,
  lib,
  ...
}:
{
  home.activation = {
    installGptme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${pkgs.uv}/bin/uv tool install gptme==0.27.0 && echo "--- Install gptme done" || true
      ## Install failed
      # run ${pkgs.uv}/bin/uv tool install gptme-rag==0.5.0 && echo "--- Install gptme-rag done" || true
    '';
  };
  xdg.configFile = {
    "gptme/config.toml" = {
      source = pkgs.replaceVars ../../conf/llm/gptme/config.toml {
        OPENROUTER_API_KEY = pkgs.nix-priv.keys.openrouter.apiKey;
      };
    };
  };
}
