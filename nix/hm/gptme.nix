{
  pkgs,
  lib,
  ...
}:
{
  home.activation = {
    # see https://github.com/gptme/gptme-rag/issues/12
    installGptme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Install gptme with browser support and httpx[socks] dependency
      run ${pkgs.uv}/bin/uv tool install --python 3.12 --with 'httpx[socks]' 'gptme[browser]==0.27.0' && echo "--- Install gptme with browser support and httpx[socks] done" || true
      # NOTE: Using Python 3.12 due to _opcode module missing in Python 3.13.5 ARM64 builds
      run ${pkgs.uv}/bin/uv tool install --python 3.12 gptme-rag==0.5.0 || true
      # setup the browser tool - install playwright browser binaries
      # First install playwright as a separate tool, then use it to install browser
      run ${pkgs.uv}/bin/uv tool install --python 3.12 playwright==1.49.1 && \
          ${pkgs.uv}/bin/uv tool run playwright install chromium-headless-shell

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
