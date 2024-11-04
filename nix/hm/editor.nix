{
  pkgs,
  config,
  ...
}: {
  nixpkgs.overlays = [
    (self: super: {
      lua-language-server = super.lua-language-server.overrideAttrs (o: rec {
        version = "3.9.1";
        src = super.fetchFromGitHub {
          owner = "luals";
          repo = "lua-language-server";
          rev = version;
          hash = "sha256-M4eTrs5Ue2+b40TPdW4LZEACGYCE/J9dQodEk9d+gpY=";
          fetchSubmodules = true;
        };
      });
    })
  ];
  home.packages = with pkgs; [
    ## build neovim
    ninja
    gettext
    curl
    # latest is required
    tree-sitter
    sqlite
    luajit
    stylua
    lua-language-server
    luarocks
    # for nix language lsp support.
    nil
    deadnix
    # markdown
    marksman
    # yaml
    yaml-language-server
    yamllint
    # for neovim
    nodePackages.neovim
    # jsonls
    vscode-langservers-extracted
    pyright
    ruff
    (python3.buildEnv.override {
      extraLibs = [
        python3Packages.pynvim
      ];
    })
    # vimPlugins.none-ls-nvim
    # nim
    # nim
    # nimlangserver
    # nimble
  ];

  home.file.".config/nvim/lua/nix-env.lua".text = ''
    vim.opt.shell = "${pkgs.fish}/bin/fish"
    vim.g.user_cfg = {
      codelldb_path = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}//share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb",
      liblldb_path = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/lib/liblldb.dylib",
      env__npm_root = "${config.home.homeDirectory}/.nix-profile",
      runtime__python3_host_prog = "${config.home.homeDirectory}/.nix-profile/bin/python3",
      runtime__node_host_prog = "${config.home.homeDirectory}/.nix-profile/bin/neovim-node-host",
      lsp_biome = "${pkgs.biome}/bin/biome",
      dap_firefox_debug_adapter_path = "${pkgs.vscode-extensions.firefox-devtools.vscode-firefox-debug}/share/vscode/extensions/firefox-devtools.vscode-firefox-debug/dist/adapter.bundle.js"
    }
  '';
}
