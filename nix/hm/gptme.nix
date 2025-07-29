{
  pkgs,
  lib,
  ...
}:
{
  home.activation = {
    # see https://github.com/gptme/gptme-rag/issues/12
    installGptme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${pkgs.uv}/bin/uv tool install --python 3.12 gptme==0.27.0 && echo "--- Install gptme done" || true
      # NOTE: Using Python 3.12 due to _opcode module missing in Python 3.13.5 ARM64 builds
      run ${pkgs.uv}/bin/uv tool install --python 3.12 gptme-rag==0.5.0 || true
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
