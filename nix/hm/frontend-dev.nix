{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    # node2nix
    fnm
    bun
    nodejs
    # biome
    nodePackages.prettier
    nodePackages.eslint
    nodePackages.typescript
    vtsls
    nodePackages.typescript-language-server
    tailwindcss-language-server
    vscode-extensions.firefox-devtools.vscode-firefox-debug
  ];

  home.sessionVariables = {
    # fnm
    FNM_DIR = "$HOME/.fnm";
    FNM_LOGLEVEL = "error";
    PNPM_HOME = "${config.xdg.dataHome}/pnpm";
  };
  home.sessionPath = [
    "${config.xdg.dataHome}/pnpm"
  ];

  programs.fish.interactiveShellInit = ''
    eval "$(fnm env --use-on-cd)"
  '';
  programs.bash.initExtra = ''
    eval "$(fnm env --use-on-cd)"
  '';
}
