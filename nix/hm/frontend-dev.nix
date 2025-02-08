{
  pkgs,
  config,
  ...
}:
{
  home.packages = with pkgs; [
    # node2nix
    fnm
    nodejs
    pnpm
    # biome
    nodePackages.prettier
    nodePackages.eslint
    nodePackages.typescript
    # vtsls
    # nodePackages.typescript-language-server
    # tailwindcss-language-server
    # vscode-extensions.firefox-devtools.vscode-firefox-debug
  ];

  home.sessionVariables = {
    # fnm
    FNM_DIR = "$HOME/.fnm";
    FNM_LOGLEVEL = "error";
    PNPM_HOME = "${config.xdg.dataHome}/pnpm";
    NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
    NPM_CONFIG_PREFIX = "${config.xdg.dataHome}/npm";
    # NPM_CONFIG_TMP = "${config.xdg.cacheHome}/npm-tmp";
    COREPACK_HOME = "${config.xdg.cacheHome}/node/corepack";
  };
  home.sessionPath = [
    "${config.xdg.dataHome}/pnpm"
    "$NPM_CONFIG_PREFIX/bin"
  ];

  programs.fish.interactiveShellInit = ''
    eval "$(fnm env)"
    # otherwise in interactive shell, npm bins not available
    fish_add_path "$NPM_CONFIG_PREFIX/bin"
  '';
  programs.bash.initExtra = ''
    eval "$(fnm env --use-on-cd)"
  '';
}
