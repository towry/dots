{
  pkgs,
  config,
  ...
}:
let
  path-prefix = config.vars.path-prefix.value;
in
{
  home.packages = with pkgs; [
    rust-mcp-filesystem
    ## build neovim
    ninja
    gettext
    curl
    # latest is required
    tree-sitter
    sqlite
    luajit
    typos-lsp
    # stylua
    # lua-language-server
    # luarocks
    # shellcheck
    # for nix language lsp support.
    nil
    deadnix
    ast-grep
    # markdown
    # marksman
    # yaml
    # yaml-language-server
    # yamllint
    # for neovim
    # nodePackages.neovim
    # jsonls
    # vscode-langservers-extracted
    # pyright
    # basedpyright
    ruff

    # vimPlugins.none-ls-nvim
    # nim
    # nim
    # nimlangserver
    # nimble
  ];

  # codelldb_path = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}//share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb",
  # liblldb_path = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/lldb/lib/liblldb.dylib",

  home.file.".config/nvim/lua/nix-env.lua".text = ''
    vim.opt.shell = "${pkgs.fish}/bin/fish"
    vim.g.user_cfg = {
      env__npm_root = "${path-prefix}",
      runtime__python3_host_prog = "${path-prefix}/bin/python3",
      runtime__node_host_prog = "${path-prefix}/bin/neovim-node-host",
      dap_firefox_debug_adapter_path = "${pkgs.vscode-extensions.firefox-devtools.vscode-firefox-debug}/share/vscode/extensions/firefox-devtools.vscode-firefox-debug/dist/adapter.bundle.js"
    }
  '';
  # home.file.".cursor/mcp.json" = {
  #   source = ../../conf/cursor/mcp.json;
  # };
}
