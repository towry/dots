{
  config,
  # pkgs,
  ...
}: {
  home.packages = [
    # pkgs.zellij
  ];
  xdg.configFile = {
    "zellij" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/conf/zellij";
      recursive = false;
    };
  };
}
