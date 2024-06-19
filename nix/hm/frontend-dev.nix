{
  pkgs,
  config,
  ...
}: let
  nodeDeps = pkgs.callPackage ../pkgs/node/default.nix {
    pkgs = pkgs;
  };
in {
  home.packages = with pkgs; [
    node2nix
    fnm
    corepack_22
    nodePackages.prettier
    nodePackages.eslint
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodeDeps.package
    tailwindcss-language-server
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
