{ config, ... }:
{
  programs.wezterm = {
    enable = false;
  };
  xdg.configFile = {
    "wezterm" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/conf/wezterm";
      recursive = false;
    };
  };
}
